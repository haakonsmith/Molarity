# Molarity

Molarity is an interactive desktop periodic table built with Electron.

## Keyboard Shortcuts

None so far :(.

## Building Project

```shell
yarn install
yarn electron:build --mac --windows --linux
```

### Package Manager

This project is built and tested with yarn, however, npm may work. Use at your own risk.

### Development

Once yarn install has been run `yarn electron:serve` will start the development server.

## Credits

### Periodicity

This project is effectively a fork of [Periodicity](https://github.com/kadinzhang/Periodicity), hence a lot of credit goes to this project as it was the inspiration and the code base for this project. The reason this project is not an actual GitHub fork is partially because of my inexperience with Git and open-source, but also because this project changes periodicity enough to be considered a different project, however, if anyone feels free to mention please open an issue.

### Built With

- [vue.js](https://github.com/vuejs/vue) (component iteration is awesome!)
  - [vuetify.js](https://github.com/vuetifyjs/vuetify)
  - [vue-router](https://github.com/vuejs/vue-router)
- [gsap](https://github.com/greensock/GreenSock-JS)

## Open-Source Technologies Used

- [periodic-table](https://www.npmjs.com/package/periodic-table)
- [periodic-Table-JSON](https://github.com/Bowserinator/Periodic-Table-JSON)
- [chart.js](https://github.com/chartjs/Chart.js)

## Molarity Lib

This is the custom library used by Molarity for various chemical things.

## Credits

### Chemical Visualisation

Part of the Molarity Lib is the chemical visualization web-component, it's based off [<chemical-element-visualisation>](https://github.com/FlorianFe/chemical-element-visualisation)

## License

This project is licensed under the MIT License – see the [LICENSE](LICENSE) file for details
