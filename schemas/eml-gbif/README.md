# EML GBIF schema plugin

EML GBIF 2.2.0 version (https://eml.ecoinformatics.org/)

## Installing the plugin

### GeoNetwork version to use with this plugin

Use GeoNetwork 3.10+. It's not supported in older versions so don't plug it into it!

### Adding the plugin to the source code

The best approach is to add the plugin as a submodule. Use https://github.com/geonetwork/core-geonetwork/blob/3.10.x/add-schema.sh for automatic deployment:
```
./add-schema.sh eml-gbif https://eos.geocat.net/gitlab/lifewatch/eml-gbif
```

### Deploy the profile in an existing installation
The plugin can be deployed manually in an existing GeoNetwork installation:

After building the application, it's possible to deploy the schema plugin manually in an existing GeoNetwork installation:

- Copy the content of the folder `schemas/eml-gbif/src/main/plugin` to `INSTALL_DIR/geonetwork/WEB-INF/data/config/schema_plugins/eml-gbif`

- Copy the jar file `schemas/eml-gbif/target/eml-gbif-3.7.jar` to `INSTALL_DIR/geonetwork/WEB-INF/lib`.

If there's no changes to the profile Java code or the configuration (`config-spring-geonetwork.xml`), the jar file is not required to be deployed each time.
