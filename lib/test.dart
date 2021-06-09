import 'dart:ffi';

import 'package:cosmosdb/cosmosdb.dart';

void main() {
    final cosmosDB = CosmosDB(
        masterKey: '9qu5XzdNZTdCNeC2ZWjWqhZbmWVCoT3qFU0M7SS1P82H00dmG8OSvqEnlEGujIpSUB6lGeyc1Q0ERsDuXirLGg==',
        baseUrl: 'https://synapseliiink.documents.azure.com:443/',
    );
    // get all documents from a collection
    void run(String region,String district, price_from, price_to) async{
      // final documents = await cosmosDB.documents.list('data', 'detail_data');
      // print(documents);
      String collectionId="final_data";
      String databaseId="data";
      String count="20";
      
      final results = await cosmosDB.documents.query2(
        Query(
            query:
                'SELECT * FROM $collectionId c where c.district=@district order by c._ts desc',
            parameters: {
              'region': DateTime.now().millisecondsSinceEpoch,
              'district': district,
              'price1':price_from,
              'price2':price_to
            }),
        databaseId ,
        collectionId,
        count
      );
      print(results.toList().length);
    }
    run("Hồ Chí Minh","Quận 1",1,10);
    // final results = cosmosDB.documents.query(
    //     Query(
    //         query:
    //             'SELECT * FROM c WHERE c.url_hash = "2ec52df92ad3febb70afe776f0a44c2a"'),
    //     'data',
    //     'detail_data',
    //   );
    // print(results);
}