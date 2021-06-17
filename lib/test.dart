import 'dart:ffi';

import 'package:cosmosdb/cosmosdb.dart';

void main() {
    final cosmosDB = CosmosDB(
        masterKey: '9qu5XzdNZTdCNeC2ZWjWqhZbmWVCoT3qFU0M7SS1P82H00dmG8OSvqEnlEGujIpSUB6lGeyc1Q0ERsDuXirLGg==',
        baseUrl: 'https://synapseliiink.documents.azure.com:443/',
    );
    // get all documents from a collection
    void run(List homepage,List category,String region,String district,String ward,double price_from,var price_to) async{
      // final documents = await cosmosDB.documents.list('data', 'detail_data');
      // print(documents);
      String collectionId="final_data";
      String databaseId="data";
      String count="100";
      List condtion=[];

      if(homepage.length==1){
        if(homepage[0] != "all"){
          String b='('+'c.homepage='+"'"+homepage[0]+"'"+')';
          condtion.add(b);
        }
      }
      else if(homepage.length==2){
        String b='('+'c.homepage='+"'"+homepage[0]+"'"+ 'or c.homepage='+"'"+homepage[1]+"'"')';
          condtion.add(b);
      }
      else if(homepage.length==3){
        String b='('+'c.homepage='+"'"+homepage[0]+"'"+ 'or c.homepage='+"'"+homepage[1]+"'"'or c.homepage='+"'"+homepage[2]+"'"')';
          condtion.add(b);
      }



      if(category.length==1){
        if(category[0] != "all"){
          String b='('+'c.category='+"'"+category[0]+"'"+')';
          condtion.add(b);
        }
      }
      else{
        String b="(";
        for(int i=0;i<category.length;i++){
            b=b+"c.category = "+"'"+category[i]+"'";
            if(i+1<category.length){
              b=b+" or ";
            }
            else{
              b=b+")";
            }
        }
        condtion.add(b);
      }


      if(region!='null'){
        String b='('+'c.region='+"'"+region+"'"+')';
          condtion.add(b);
      }

      if(district!='null'){
        String b='('+'c.district='+"'"+district+"'"+')';
          condtion.add(b);
      }

      if(ward!='null'){
        String b='('+'c.ward='+"'"+ward+"'"+')';
          condtion.add(b);
      }

      condtion.add('('+'c.price>'+price_from.toString()+')');
      if(price_to.runtimeType==double){
        condtion.add('('+'c.price<'+price_to.toString()+')');
      }
      String query='SELECT * FROM $collectionId c where ';
        for(int i=0;i<condtion.length;i++){
          query=query+condtion[i];
          if(i+1<condtion.length){
            query=query+" and ";
          }
        }
      print(query);
      // else if(category.length==2){
      //   String b='('+'c.category='+"'"+category[0]+"'"+ 'and c.category='+"'"+category[1]+"'"')';
      //     condtion.add(b);
      // }
      // else if(homepage.length==3){
      //   String b='('+'c.homepage='+"'"+homepage[0]+"'"+ 'and c.homepage='+"'"+homepage[1]+"'"'and c.homepage='+"'"+homepage[2]+"'"')';
      //     condtion.add(b);
      // }


      final results = await cosmosDB.documents.query(
        Query(
            query:
                query,
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
    run(["chotot.com","nhadat247"],['nhà','chung cư'],"Hồ Chí Minh","d 10","null",1,"100+");
    // List a=['chotot.com','nhadat247.com.vn'];
    // List c=['nhà','chung cư'];
    // List e=[];
    // if(a.length==2){
    //   String b='('+'c.homepage='+"'"+a[0]+"'"+ 'and c.homepage='+"'"+a[1]+"'"')';
    //   e.add(b);
    // }
    // if(c.length==2){
    //   String b='('+'c.category='+"'"+c[0]+"'"+ 'and c.category='+"'"+c[1]+"'"')';
    //   e.add(b);
    // }
    // print(e);
    // String query=' where ';
    // for(int i=0;i<e.length;i++){
    //   query=query+e[i];
    //   if(i+1<e.length){
    //     query=query+" and ";
    //   }
    // }
    // print(query);
    // // final results = cosmosDB.documents.query(
    //     Query(
    //         query:
    //             'SELECT * FROM c WHERE c.url_hash = "2ec52df92ad3febb70afe776f0a44c2a"'),
    //     'data',
    //     'detail_data',
    //   );
    // print(results);
}