import 'dart:ffi';

import 'package:cosmosdb/cosmosdb.dart';

void main() {
    final cosmosDB = CosmosDB(
      masterKey: 'r0EEApAfBwKARscLmgjPzdAYVVxFbLy5pOf2AU0yLL6FrcHFjySI3NYnb5zpHSvVPFkvRKI4yUTTRIZTmt4mCg==',
      baseUrl: 'https://synapsel1nk.documents.azure.com:443/',
    );
    // get all documents from a collection
    void run(String region,String district, price_from, price_to) async{
      // final documents = await cosmosDB.documents.list('data', 'detail_data');
      // print(documents);
      String collectionId="final_data";
      String databaseId="data";
      final results = await cosmosDB.documents.query(
        Query(
            query:
                'SELECT c.url_hash,c.bedrooms FROM $collectionId c where c.region=@region and c.district=@district and c.price < @price2 and c.price > @price1',
            parameters: {
              'region': region,
              'district': district,
              'price1':price_from,
              'price2':price_to
            }),
        databaseId ,
        collectionId,
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