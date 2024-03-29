# Sumo Logic Account Setup

How to configure your Sumo Logic account for use with Sensu Go.

- [HTTP Logs and Metrics Source](#http-logs-and-metrics-source)
- [Update the Sumo Logic secret in the workshop](#update-the-sumo-logic-secret-in-the-workshop)
- [Sensu Dashboards](#sensu-dashboards)

## HTTP Logs and Metrics Source

Follow these instructions to configure a [HTTP Logs and Metrics Source][http-source] for collecting observability data from Sensu.

1. **Create a new Hosted Collector.**

   - Navigate to the ["Collection" tab][collection] in Sumo Logic
   - Click "add collector"

     ![](img/add-collector-02.png)

   - Choose a "Hosted Collector"

     ![](img/add-collector-03.png)

   - Name the hosted collector "sensu"

     ![](img/add-collector-04.png)

   - Save the hosted collector

2. **Add a Data Source to the Hosted Collector.**

   - When prompted to "add a data source to your new collector", choose "OK"; alternatively, navigate back to the ["Collection" tab][collection] and click "add source" next to your new `sensu` Hosted Collector

     ![](img/add-collector-05.png)

   - Select "HTTP Logs & Metrics" under "Cloud APIs"

     ![](img/add-collector-06.png)

   - Name the source `sensu-http`

     ![](img/add-collector-07.png)

   - Set the source category to `sensu-events`
   - Save the source
   - When prompted, copy the "HTTP Source Address"

     ![](img/add-collector-08.png)

_NOTE: to retrieve this HTTP Source Address at a later time, navigate to the ["Collection" tab][collection] in Sumo Logic and click "Show URL" next to the `sensu-http` source._

## Update the Sumo Logic secret in the workshop

Follow these steps to update the Sumo Logic HTTP source secret in Sensu.

1. **Edit the `.env` file**

   Replace the line with the example `SUMOLOGIC_HTTP_SOURCE_URL` environment variable

   ```
   SUMOLOGIC_HTTP_SOURCE_URL=https://endpointX.collection.sumologic.com/receiver/v1/http/xxxxxxxxxxxxxxxxxxxx
   ```

   Replace this value with the URL you obtained in the last step when created you [HTTP Logs and Metrics Source](#http-logs-and-metrics-source) (above).

2. **Reload the workshop**

   To "deploy" this environment variable and make it available in the workshop, please run the following command:

   ```shell
   sudo docker-compose up -d
   ```

   The output should look something like this:

   ```
   $ sudo docker-compose up -d
   workshop_vault_1 is up-to-date
   workshop_mongo_1 is up-to-date
   workshop_sensu-agent_1 is up-to-date
   workshop_sensu-assets_1 is up-to-date
   workshop_sensu-assets-smb_1 is up-to-date
   Recreating workshop_sensu-backend_1 ...
   Recreating workshop_sensu-backend_1 ... done
   Recreating workshop_sensuctl_1      ... done
   Recreating workshop_configurator_1  ... done
   ```

   If you see `Recreating workshop_sensu-backend_1 ... done`, then you're all set!

## Sensu Dashboards

Follow these instructions to configure a Sensu Overview dashboard (hostmaps), and Sensu Entity Detail dashboard.

1. **Navigate to your [Sumo Logic home page][home]**

2. **Browse to a folder where you want to import content and choose import**

   Click the options menu.

   ![](img/add-dashboards-00.png)

   Select "Import".

   ![](img/add-dashboards-01.png)


   _NOTE: see ["Import Content in the Library"][import] for more information._

3. **Name your content "Sensu"**

   ![](img/add-dashboards-02.png)

4. **Copy and paste the following JSON configuration into the "Import Content" dialog**

   Sensu Dashboards JSON

   <details>

   ```json
   {
     "type": "FolderSyncDefinition",
     "name": "Sensu",
     "description": "Sensu Go Dashboards",
     "children": [
         {
             "type": "DashboardV2SyncDefinition",
             "name": "Sensu Entity Details",
             "description": "Sensu Entity host metrics and events overview.",
             "title": "Sensu Entity Details",
             "rootPanel": null,
             "theme": "Light",
             "topologyLabelMap": {
                 "data": {}
             },
             "refreshInterval": 0,
             "timeRange": {
                 "type": "BeginBoundedTimeRange",
                 "from": {
                     "type": "RelativeTimeRangeBoundary",
                     "relativeTime": "-3h"
                 },
                 "to": null
             },
             "layout": {
                 "layoutType": "Grid",
                 "layoutStructures": [
                     {
                         "key": "panel07C8C24D85246949",
                         "structure": "{\"height\":8,\"width\":12,\"x\":0,\"y\":0}"
                     },
                     {
                         "key": "panelPANE-679CCBDEA325EA46",
                         "structure": "{\"height\":8,\"width\":12,\"x\":12,\"y\":0}"
                     },
                     {
                         "key": "panelPANE-07A5D753A4759B4B",
                         "structure": "{\"height\":8,\"width\":24,\"x\":0,\"y\":8}"
                     }
                 ]
             },
             "panels": [
                 {
                     "id": null,
                     "key": "panel07C8C24D85246949",
                     "title": "CPU Used",
                     "visualSettings": "{\"general\":{\"mode\":\"timeSeries\",\"type\":\"line\",\"displayType\":\"default\",\"markerSize\":5, \"lineDashType\":\"solid\",\"markerType\":\"none\",\"lineThickness\":1},\"title\":{\"fontSize\":14},\"axes\":{\"axisX\": {\"title\":\"\",\"titleFontSize\":11,\"labelFontSize\":10},\"axisY\":{\"title\":\"\",\"titleFontSize\":11,\"labelFontSize\":12, \"logarithmic\":false,\"unit\":{\"value\":\"%\",\"isCustom\":false}}},\"legend\":{\"enabled\":true,\"verticalAlign\":\"bottom\", \"fontSize\":12,\"maxHeight\":50,\"showAsTable\":false,\"wrap\":true},\"color\":{\"family\":\"Categorical Default\"}, \"hiddenQueryKeys\":[\"B\"],\"overrides\":[{\"series\":[],\"queries\":[\"A\"],\"properties\":{\"name\":\"CPU Used ({{ entity }}/{ { cpu }})\"}}],\"series\":{}}",
                     "keepVisualSettingsConsistentWithParent": true,
                     "panelType": "SumoSearchPanel",
                     "queries": [
                         {
                             "queryString": "metric=system_cpu_used entity={{ entity }} namespace={{ namespace }} | eval _value * .01",
                             "queryType": "Metrics",
                             "queryKey": "A",
                             "metricsQueryMode": "Advanced",
                             "metricsQueryData": null,
                             "tracesQueryData": null,
                             "parseMode": "Auto",
                             "timeSource": "Message"
                         }
                     ],
                     "description": "",
                     "timeRange": {
                         "type": "BeginBoundedTimeRange",
                         "from": {
                             "type": "RelativeTimeRangeBoundary",
                             "relativeTime": "-3h"
                         },
                         "to": null
                     },
                     "coloringRules": null,
                     "linkedDashboards": []
                 },
                 {
                     "id": null,
                     "key": "panelPANE-679CCBDEA325EA46",
                     "title": "Memory Used",
                     "visualSettings": "{\"general\":{\"mode\":\"timeSeries\",\"type\":\"line\",\"displayType\":\"default\",\"markerSize\":5, \"lineDashType\":\"solid\",\"markerType\":\"none\",\"lineThickness\":1},\"title\":{\"fontSize\":14},\"axes\":{\"axisX\": {\"title\":\"\",\"titleFontSize\":12,\"labelFontSize\":12},\"axisY\":{\"title\":\"\",\"titleFontSize\":12,\"labelFontSize\":12, \"logarithmic\":false,\"unit\":{\"value\":\"%\",\"isCustom\":false},\"unitDecimals\":0,\"hideLabels\":false}},\"legend\": {\"enabled\":true,\"verticalAlign\":\"bottom\",\"fontSize\":12,\"maxHeight\":50,\"showAsTable\":false,\"wrap\":true},\"color\": {\"family\":\"Categorical Default\"},\"series\":{},\"overrides\":[{\"series\":[],\"queries\":[\"A\"],\"properties\": {\"name\":\"Memory used ({{ entity }})\"}}]}",
                     "keepVisualSettingsConsistentWithParent": true,
                     "panelType": "SumoSearchPanel",
                     "queries": [
                         {
                             "queryString": "metric=system_mem_used entity={{ entity }} namespace={{ namespace }} | eval _value * .01",
                             "queryType": "Metrics",
                             "queryKey": "A",
                             "metricsQueryMode": "Advanced",
                             "metricsQueryData": null,
                             "tracesQueryData": null,
                             "parseMode": "Auto",
                             "timeSource": "Message"
                         }
                     ],
                     "description": "",
                     "timeRange": {
                         "type": "BeginBoundedTimeRange",
                         "from": {
                             "type": "RelativeTimeRangeBoundary",
                             "relativeTime": "-3h"
                         },
                         "to": null
                     },
                     "coloringRules": null,
                     "linkedDashboards": []
                 },
                 {
                     "id": null,
                     "key": "panelPANE-07A5D753A4759B4B",
                     "title": "Sensu Events (per 5m interval)",
                     "visualSettings": "{\"title\":{\"fontSize\":14},\"axes\":{\"axisX\":{\"title\":\"Bucket (5m)\",\"titleFontSize\":12, \"labelFontSize\":12,\"hideLabels\":true},\"axisY\":{\"title\":\"Events\",\"titleFontSize\":12,\"labelFontSize\":12, \"logarithmic\":false,\"hideLabels\":false}},\"legend\":{\"enabled\":false,\"verticalAlign\":\"bottom\",\"fontSize\":12, \"maxHeight\":50,\"showAsTable\":false,\"wrap\":true},\"series\":{},\"general\":{\"type\":\"column\",\"displayType\":\"stacked\", \"fillOpacity\":0.75,\"mode\":\"timeSeries\"},\"color\":{\"family\":\"Categorical Light\"},\"overrides\":[{\"series\":[\"0\"], \"queries\":[],\"properties\":{\"color\":\"#6cae01\",\"name\":\"OK\"}},{\"series\":[\"1\"],\"queries\":[],\"properties\": {\"color\":\"#f2da73\",\"name\":\"WARNING\"}},{\"series\":[\"2\"],\"queries\":[],\"properties\":{\"color\":\"#bf2121\", \"name\":\"CRITICAL\"}}]}",
                     "keepVisualSettingsConsistentWithParent": true,
                     "panelType": "SumoSearchPanel",
                     "queries": [
                         {
                             "queryString": "_sourceCategory=sensu-event _sourceHost={{ entity }} | json \"$check.metadata.name\",\"$check.status\", \"$check.metadata.namespace\" as check_name, check_status, check_namespace | timeslice 5m | count by _timeslice, check_status | transpose row _timeslice column check_status",
                             "queryType": "Logs",
                             "queryKey": "A",
                             "metricsQueryMode": null,
                             "metricsQueryData": null,
                             "tracesQueryData": null,
                             "parseMode": "Auto",
                             "timeSource": "Message"
                         }
                     ],
                     "description": "",
                     "timeRange": {
                         "type": "BeginBoundedTimeRange",
                         "from": {
                             "type": "RelativeTimeRangeBoundary",
                             "relativeTime": "-3h"
                         },
                         "to": null
                     },
                     "coloringRules": null,
                     "linkedDashboards": []
                 }
             ],
             "variables": [
                 {
                     "id": null,
                     "name": "entity",
                     "displayName": "entity",
                     "defaultValue": "*",
                     "sourceDefinition": {
                         "variableSourceType": "MetadataVariableSourceDefinition",
                         "filter": "namespace={{namespace}}",
                         "key": "entity"
                     },
                     "allowMultiSelect": false,
                     "includeAllOption": true,
                     "hideFromUI": false
                 },
                 {
                     "id": null,
                     "name": "namespace",
                     "displayName": "namespace",
                     "defaultValue": "*",
                     "sourceDefinition": {
                         "variableSourceType": "MetadataVariableSourceDefinition",
                         "filter": "",
                         "key": "namespace"
                     },
                     "allowMultiSelect": false,
                     "includeAllOption": true,
                     "hideFromUI": false
                 }
             ],
             "coloringRules": []
         },
         {
             "type": "DashboardV2SyncDefinition",
             "name": "Sensu Overview",
             "description": "Overview of systems under management by Sensu Go (grouped by namespace and host OS)",
             "title": "Sensu Overview",
             "rootPanel": null,
             "theme": "Light",
             "topologyLabelMap": {
                 "data": {}
             },
             "refreshInterval": 0,
             "timeRange": {
                 "type": "BeginBoundedTimeRange",
                 "from": {
                     "type": "RelativeTimeRangeBoundary",
                     "relativeTime": "-1h"
                 },
                 "to": null
             },
             "layout": {
                 "layoutType": "Grid",
                 "layoutStructures": [
                     {
                         "key": "panelPANE-BBD3A0C69A056A4D",
                         "structure": "{\"height\":9,\"width\":24,\"x\":0,\"y\":9}"
                     },
                     {
                         "key": "panel4030198BAD7CA940",
                         "structure": "{\"height\":9,\"width\":24,\"x\":0,\"y\":0}"
                     }
                 ]
             },
             "panels": [
                 {
                     "id": null,
                     "key": "panelPANE-BBD3A0C69A056A4D",
                     "title": "Entity Hostmap (CPU used by OS)",
                     "visualSettings": "{\"general\":{\"mode\":\"honeyComb\",\"type\":\"honeyComb\",\"displayType\":\"default\"},\"title\": {\"fontSize\":14},\"honeyComb\":{\"thresholds\":[{\"from\":0,\"to\":7,\"color\":\"#98ECA9\"},{\"from\":7,\"to\":20, \"color\":\"#F2DA73\"},{\"from\":20,\"to\":1000,\"color\":\"#FFB5B5\"}],\"shape\":\"hexagon\",\"groupBy\":[{\"label\":\"os\", \"value\":\"os\"},{\"label\":\"platform\",\"value\":\"platform\"}],\"aggregationType\":\"latest\"},\"series\":{},\"overrides\":[ {\"series\":[],\"queries\":[\"A\"],\"properties\":{}}],\"legend\":{\"enabled\":false}}",
                     "keepVisualSettingsConsistentWithParent": true,
                     "panelType": "SumoSearchPanel",
                     "queries": [
                         {
                             "queryString": "metric=system_cpu_used cpu=cpu-total entity={{ entity }} namespace={{ namespace }} | avg by namespace, entity,os,platform",
                             "queryType": "Metrics",
                             "queryKey": "A",
                             "metricsQueryMode": "Advanced",
                             "metricsQueryData": null,
                             "tracesQueryData": null,
                             "parseMode": "Auto",
                             "timeSource": "Message"
                         }
                     ],
                     "description": "",
                     "timeRange": null,
                     "coloringRules": null,
                     "linkedDashboards": [
                         {
                             "id": "siiult0ek2agirapE1HP7MdK8QA9z1sSWoAvprF1po1W5JWCJVL65HLJtV5M",
                             "relativePath": "../Sensu Entity Details",
                             "includeTimeRange": true,
                             "includeVariables": true
                         }
                     ]
                 },
                 {
                     "id": null,
                     "key": "panel4030198BAD7CA940",
                     "title": "Entity Hostmap (CPU used by Sensu Namespace)",
                     "visualSettings": "{\"general\":{\"mode\":\"honeyComb\",\"type\":\"honeyComb\",\"displayType\":\"default\"},\"title\": {\"fontSize\":14},\"honeyComb\":{\"thresholds\":[{\"from\":0,\"to\":7,\"color\":\"#98ECA9\"},{\"from\":7,\"to\":20, \"color\":\"#F2DA73\"},{\"from\":20,\"to\":1000,\"color\":\"#FFB5B5\"}],\"shape\":\"hexagon\",\"groupBy\":[ {\"label\":\"namespace\",\"value\":\"namespace\"}],\"aggregationType\":\"latest\"},\"series\":{},\"overrides\":[{\"series\":[], \"queries\":[\"A\"],\"properties\":{}}],\"legend\":{\"enabled\":false}}",
                     "keepVisualSettingsConsistentWithParent": true,
                     "panelType": "SumoSearchPanel",
                     "queries": [
                         {
                             "queryString": "metric=system_cpu_used cpu=cpu-total entity={{ entity }} namespace={{ namespace }}  | avg by namespace, entity,os,platform",
                             "queryType": "Metrics",
                             "queryKey": "A",
                             "metricsQueryMode": "Advanced",
                             "metricsQueryData": null,
                             "tracesQueryData": null,
                             "parseMode": "Auto",
                             "timeSource": "Message"
                         }
                     ],
                     "description": "",
                     "timeRange": null,
                     "coloringRules": null,
                     "linkedDashboards": [
                         {
                             "id": "siiult0ek2agirapE1HP7MdK8QA9z1sSWoAvprF1po1W5JWCJVL65HLJtV5M",
                             "relativePath": "../Sensu Entity Details",
                             "includeTimeRange": true,
                             "includeVariables": true
                         }
                     ]
                 }
             ],
             "variables": [
                 {
                     "id": null,
                     "name": "entity",
                     "displayName": "entity",
                     "defaultValue": "*",
                     "sourceDefinition": {
                         "variableSourceType": "MetadataVariableSourceDefinition",
                         "filter": "namespace={{namespace}}",
                         "key": "entity"
                     },
                     "allowMultiSelect": false,
                     "includeAllOption": true,
                     "hideFromUI": false
                 },
                 {
                     "id": null,
                     "name": "namespace",
                     "displayName": "namespace",
                     "defaultValue": "*",
                     "sourceDefinition": {
                         "variableSourceType": "MetadataVariableSourceDefinition",
                         "filter": "",
                         "key": "namespace"
                     },
                     "allowMultiSelect": false,
                     "includeAllOption": true,
                     "hideFromUI": false
                 }
             ],
             "coloringRules": []
         }
     ]
   }
   ```

   </details>

5. **Click "Import" to import the dashboard**

6. **If the new dashboards aren't immediately visible in Sumo Logic, you may need to refresh your browser**

   ![](img/add-dashboards-04.png)

   Success!



<!-- Links -->
[http-source]: https://help.sumologic.com/03Send-Data/Sources/02Sources-for-Hosted-Collectors/HTTP-Source
[collection]: https://service.sumologic.com/ui/#/collection/collection
[home]: https://service.sumologic.com/ui/#/home
[import]: https://help.sumologic.com/01Start-Here/Library/Export-and-Import-Content-in-the-Library#import-content-in-the-library
