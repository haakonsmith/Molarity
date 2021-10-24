import 'dart:async';
import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:molarity/widgets/chemoinfomatics/data.dart';
import 'package:sortedmap/sortedmap.dart';

enum PubChemProperties { MolecularFormula, MolecularWeight, Title }

typedef ListKey = int;

/// This is a subclass of [CompoundData], meaning that it expands on the properties that compound data has.
/// This has been done because, due to the nature of pubchem, [PubChemCompoundData] is likely going to be a really heavy object,
/// thus only using it if necessary would be desirable. However, this is probably mitigated by the fact that dart isn't C++.
class PubChemCompoundData extends CompoundData with Comparable {
  PubChemCompoundData(this.cid, this.title, this.molecularWeight, this.pubchemCompoundDesignation) : super.empty();

  PubChemCompoundData.fromJson(Map json, [CompoundData? compoundFormula])
      : cid = json['CID'],
        title = json['Title'],
        pubchemCompoundDesignation = json['Title'],
        molecularWeight = double.parse(json['MolecularWeight']),
        super.empty() {
    if (compoundFormula != null) rawCompound.addAll(compoundFormula.rawCompound);
  }

  final String? pubchemCompoundDesignation;
  final int? cid;
  final String? title;
  final double? molecularWeight;

  double distanceTo(PubChemCompoundData other) {
    double distance = distanceToBasic(other);

    return distance;
  }

  /// Dart is a pansy language without operator overloading.
  double distanceToBasic(CompoundData other) {
    double distance = 0;

    if (molecularWeight != null && other.molarMass != null) distance += (other.molarMass - molecularWeight!).abs();

    return distance;
  }

  @override
  int compareTo(other) {
    assert(other is PubChemCompoundData);

    final distance = distanceTo(other);

    if (distance > 0)
      return -1;
    else
      return 1;
  }

  @override
  String toString() => cid.toString() + (title ?? 'Unknown Title') + molecularWeight.toString();
}

/// This is a http client for pubchem rest. This is not entirely self contained, as it required [CompoundData] from another part of the code.
///
/// TODO(haakonsmith): profile and improve performance on large queries, .
/// TODO(haakonsmith): possibly move these decoding functions into a compute function to save performance,
/// TODO(haakonsmith): expand the capabilities to the full range of properties and further`,
class PubChemClient {
  PubChemClient() : client = http.Client();

  final http.Client client;

  static const String authority = 'pubchem.ncbi.nlm.nih.gov';
  static const String dataType = 'JSON';

  /// This caches listkeys, these keys will be valid with pubchem, because they are invalidated, internally, quite quickly.
  final Map<Uri, ListKey> listKeyCache = {};

  final Map<String, Map> searchCache = {};

  /// This is a set, because there cannot be any duplicate properties, also, I wanna be able to easily attempt to add properties.
  Future<PubChemCompoundData> getPropertiesOf(CompoundData compound, Set<PubChemProperties> properties) async {
    final listKey = await searchByFormula(compound, maxRecords: 10);

    properties.add(PubChemProperties.MolecularFormula);
    properties.add(PubChemProperties.MolecularWeight);

    final pubChemResults = await getPropertiesFrom(listKey, properties: properties);

    final results = _sortCompoundResultsByReference(pubChemResults, compound);

    return results[0];
  }

  Future<ListKey> searchByFormula(CompoundData compound, {int maxRecords = 10, bool allowOtherElements = false}) async {
    final url = Uri.https(
      authority,
      '/rest/pug/compound/formula/${compound.toMolecularFormula()}/$dataType',
      {'AllowOtherElements': allowOtherElements.toString(), 'MaxRecords': maxRecords.toString()},
    );

    final response = await client.get(url);

    final decodedResponse = (jsonDecode(utf8.decode(response.bodyBytes)) as Map)['Waiting'] as Map;

    if (decodedResponse['Message'] != 'Your request is running') return Future.error('HTTPS failed');

    print(PubChemProperties.MolecularFormula.toString());

    return int.parse(decodedResponse['ListKey']);
  }

  Future<List<PubChemCompoundData>> getPropertiesFrom(ListKey listKey, {required Set<PubChemProperties> properties}) async {
    final url = Uri.https(
      authority,
      '/rest/pug/compound/listkey/$listKey/property/${properties.map((e) => e.toString().replaceFirst('PubChemProperties.', '')).toList().join(',')}/JSON',
    );

    final Map response = await getSearchFromListKey(url);

    return Future.value((response['PropertyTable']['Properties'] as List).map((e) => PubChemCompoundData.fromJson(e)).toList());
  }

  Future<Map> getSearchFromListKey(Uri url) async {
    final response = await client.get(url);

    var finalResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;

    bool shouldTestIfComplete = true;
    bool responseVerified = !_responseIsCompleted(finalResponse);

    int i = 1;

    if (responseVerified)
      while (shouldTestIfComplete) {
        print("testing....");

        final response = await get(url);

        final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
        print(decodedResponse);

        if (_responseIsCompleted(decodedResponse)) {
          responseVerified = true;
          finalResponse = decodedResponse;
          shouldTestIfComplete = false;
          break;
        }

        if (i > 10) {
          shouldTestIfComplete = false;
          break;
        }

        i++;

        print("failed response");
        await Future.delayed(const Duration(seconds: 1));
      }

    if (!responseVerified) return Future.error('Timeout');

    return finalResponse;
  }

  bool _responseIsCompleted(Map json) => !json.containsKey('Waiting');

  /// PubChem + HTTP seems to randomly error, so let's just give it another shot 🙃
  Future<http.Response> get(Uri url, [int retryAttempts = 3, bool shouldTestCache = true]) async {
    int tries = 0;

    bool shouldRetry = true;

    http.Response? response;

    while (tries < retryAttempts && shouldRetry) {
      shouldRetry = false;

      try {
        response = await client.get(url);
      } catch (e) {
        print(e);
        shouldRetry = true;
      }

      tries++;
    }

    print('Number of tries taken: ${tries.toString()}');

    if (tries > retryAttempts) return Future.error("Exceeded retry limit");

    return Future.value(response!);
  }

  List<PubChemCompoundData> _sortCompoundResultsByReference(List<PubChemCompoundData> data, CompoundData compound) {
    final List<PubChemCompoundData> result = [];

    final splayTree = SortedMap<int, double>(const Ordering.byValue());

    for (int i = 0; i < data.length; i++) splayTree[i] = data[i].distanceToBasic(compound);

    for (final int index in splayTree.keys) result.add(data[index]);

    return result;
  }

  // https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/formula/C10H21N/JSON?AllowOtherElements=true&MaxRecords=10
}

final pubChemClientProvider = Provider((_) => PubChemClient());
