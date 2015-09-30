# Insects-PhoneApp
Phone app for acoustics classification of insects

This phone app is based on AzureML GeneralInsectClassifier.

Currently the web service API is :

input: 

{
  "Inputs": {
    "Audio": {
      "ColumnNames": [
        "Samples"
      ],
      "Values": [
        [
          "0"
        ],
        [
          "0"
        ]
      ]
    }
  },
  "GlobalParameters": {
    "sampleRate": "44100",
    "bitsPerSample": "16"
  }
}



output:

{
  "Results": {
    "Classification": {
      "type": "DataTable",
      "value": {
        "ColumnNames": [
          "Acrididae(grasshopper)",
          "Cicadidae(cicada)",
          "Gryllidae(cricket)",
          "Gryllotalpidae(mole cricket)",
          "No Insect",
          "Tettigoniidae(bush cricket)"
        ],
        "ColumnTypes": [
          "Numeric",
          "Numeric",
          "Numeric",
          "Numeric",
          "Numeric",
          "Numeric"
        ],
        "Values": [
          [
            "0",
            "0",
            "0",
            "0",
            "0",
            "0"
          ],
          [
            "0",
            "0",
            "0",
            "0",
            "0",
            "0"
          ]
        ]
      }
    }
  }
}
