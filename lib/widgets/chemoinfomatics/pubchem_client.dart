import 'dart:async';
import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:molarity/widgets/chemoinfomatics/data.dart';

enum PubChemProperties { MolecularFormula, MolecularWeight, Title }

typedef ListKey = int;

class PubChemCompoundData extends CompoundData {
  PubChemCompoundData(this.cid) : super.empty();

  PubChemCompoundData.fromJson(Map json, [CompoundData? compoundFormula])
      : cid = json['CID'],
        super.empty() {
    if (compoundFormula != null) rawCompound.addAll(compoundFormula.rawCompound);
  }

  final int cid;
}

class PubChemClient {
  PubChemClient() : client = http.Client();

  final http.Client client;

  static const String authority = 'pubchem.ncbi.nlm.nih.gov';
  static const String dataType = 'JSON';

  void getProperties(CompoundData compound, List<PubChemProperties> properties) {
    // compound.toMolecularFormula()
  }

  Future<ListKey> searchByFormula(CompoundData compound, {int maxRecords = 10}) async {
    final url = Uri.https(
      authority,
      '/rest/pug/compound/formula/${compound.toMolecularFormula()}/$dataType',
      {'AllowOtherElements': 'true', 'MaxRecords': maxRecords.toString()},
    );

    final response = await client.get(url);

    final decodedResponse = (jsonDecode(utf8.decode(response.bodyBytes)) as Map)['Waiting'] as Map;

    if (decodedResponse['Message'] != 'Your request is running') return Future.error('HTTPS failed');

    print(PubChemProperties.MolecularFormula.toString());

    return int.parse(decodedResponse['ListKey']);
  }

  Future<List<PubChemCompoundData>> getPropertiesFrom(ListKey listKey, {required List<PubChemProperties> properties}) async {
    final url = Uri.https(
      authority,
      '/rest/pug/compound/listkey/$listKey/property/${properties.map((e) => e.toString().replaceFirst('PubChemProperties.', '')).toList().join(',')}/JSON',
    );

    print(url);

    final response = await getListKey(url);

    print(response);
    return Future.value((response['PropertyTable']['Properties'] as List).map((e) => PubChemCompoundData.fromJson(e)).toList());
  }

  Future<Map> getListKey(Uri url) async {
    final response = await client.get(url);

    var finalResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;

    print(finalResponse);

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

        if (i > 4) {
          shouldTestIfComplete = false;
          break;
        }

        i++;

        print("failed response");
        await Future.delayed(const Duration(seconds: 1));
      }

    if (!responseVerified) return Future.error("Timeout");

    return finalResponse;
  }

  bool _responseIsCompleted(Map json) => !json.containsKey('Waiting');

  Future<http.Response> get(Uri url, [int retryAttempts = 3, int tries = 0]) async {
    try {
      final response = await client.get(url);
    } catch (e) {
      // if (e) {
      print(e);
      if (tries <= retryAttempts) return get(url, retryAttempts, ++tries);
      // } else
      //   rethrow;
    }

    return Future.error("Get error");
  }

  // https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/formula/C10H21N/JSON?AllowOtherElements=true&MaxRecords=10
}

final pubChemClientProvider = Provider((_) => PubChemClient());
