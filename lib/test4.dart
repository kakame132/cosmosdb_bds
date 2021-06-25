import 'dart:ffi';

import 'package:cosmosdb/cosmosdb.dart';
import 'package:stats/stats.dart';
import 'package:intl/intl.dart';


final cosmosDB = CosmosDB(
        masterKey: 'NivTYKZvt56pqDRtq7lQCJJ7Xs7nCo2RzPkOkAkHjUygx3D0dqAHfGF4edxoJFXSOvCzOkwF1PFoGqgYMnFrfw==',
        baseUrl: 'https://synapselynk1.documents.azure.com:443/',
    );
// get all documents from a collection
Future<List> run(List homepage,List category,String region,String district) async{
  // final documents = await cosmosDB.documents.list('data', 'detail_data');
  // print(documents);
  String collectionId="final_data";
  String databaseId="data";
  String count="-1";
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
  String query='SELECT c.surface, c.date, c.price FROM $collectionId c where ';
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
          'district': district
        }),
    databaseId ,
    collectionId,
    count
  );
  return results.toList();
}
List get_input(List c){
  DateFormat format = DateFormat.yM();

  List keys=[];
  List values=[];
  for(int i=0;i<c.length;i++){
    List b=c[i]['date'].split("/");
    c[i]['date']=b[1]+"/"+b[2];
  }
  for(int i=0;i<c.length;i++){
    double c_surface=double.parse(c[i]['surface']);
    var c_price=c[i]['price'];
    if(c_surface!=0){
      {if(keys.contains(c[i]['date'])){
        values[keys.indexOf(c[i]['date'])][0]=values[keys.indexOf(c[i]['date'])][0]+c_price/c_surface;
        values[keys.indexOf(c[i]['date'])][1]=values[keys.indexOf(c[i]['date'])][1]+1;

      }
      else{
        keys.add(c[i]['date']);
        List a=[c_price/c_surface,1];
        values.add(a);
      }}
  }
  }
  print(keys);
  for(int i=0;i<values.length;i++){
    values[i]=values[i][0]/values[i][1];
  }
  print(values);
  List compare=[];
  for(int i=0;i<keys.length;i++){
    List x=keys[i].split("/");
    int y=int.parse(x[0])+int.parse(x[1])*100;
    compare.add(y);
  }
  compare.sort((a, b) => a.compareTo(b));
  print(compare);

  List final_keys=List.filled(keys.length, '');
  List final_values=List.filled(values.length, 0);
  for(int i=0;i<keys.length;i++){
    List x=keys[i].split("/");
    int y=int.parse(x[0])+int.parse(x[1])*100;
    final_keys[compare.indexOf(y)]=keys[i];
    final_values[final_keys.indexOf(keys[i])]=values[keys.indexOf(keys[i])];
  }
  print("*****"); 
  print(final_keys);
  print(final_values);

  List result=[];
  for(int i=0;i<final_keys.length;i++){
    Map x={final_keys[i]:final_values[i]};
    result.add(x);
  }
  return result;
}
void main() async {

  List a= await  run(["chotot.com","nhadat247"],['nhà'],"Hồ Chí Minh","d 10");
  print(a[0]);
  List b=get_input(a);
  //lay label 
  print(b[0].keys);
  //lay value
  print(b[0].values);
}