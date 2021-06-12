import 'dart:ffi';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cosmosdb/cosmosdb.dart';

final cosmosDB = CosmosDB(
  masterKey: '9qu5XzdNZTdCNeC2ZWjWqhZbmWVCoT3qFU0M7SS1P82H00dmG8OSvqEnlEGujIpSUB6lGeyc1Q0ERsDuXirLGg==',
  baseUrl: 'https://synapseliiink.documents.azure.com:443/',
);
// get all documents from a collection
Future<List> get_district(String model,String region,String district) async{
  // final documents = await cosmosDB.documents.list('data', 'detail_data');
  // print(documents);
  var collectionId="final_data";
  var databaseId="data";
  String count="-1";
  final results = await cosmosDB.documents.query(
    Query(
        query:
            'SELECT * FROM $collectionId c where c.homepage=@model and c.district=@district and c.region=@region ',
        parameters: {
          'model': model,
          'region': region,
          'district': district
        }),
    databaseId ,
    collectionId,
    count
  );
  
    return results.toList();
}
Future<List> get_street(String model,String region,String district,String street) async{
  // final documents = await cosmosDB.documents.list('data', 'detail_data');
  // print(documents);
  var collectionId="final_data";
  var databaseId="data";
  String count="-1";
  final results = await cosmosDB.documents.query(
    Query(
        query:
            'SELECT * FROM $collectionId c where c.homepage=@model and c.district=@district and c.region=@region and c.street=@street',
        parameters: {
          'model': model,
          'region': region,
          'district': district,
          'street':  street
        }),
    databaseId ,
    collectionId,
    count
  );
  return results.toList();
}
void address_split(a,List c){
  List x=a.split(" > ");
  //region
  if (x[0].contains('Thành phố')){
    c.add(x[0].split("Thành phố ")[1]);
  }
  else if (x[0].contains('Tỉnh')) {
      c.add(x[0].split("Tỉnh ")[1]);
  }
  else{
          c.add(x[0]);
  }
  //district
  if (x[1].contains('Quận')){
        c.add("d "+x[1].split("Quận ")[1]);
  }
  else if(x[1].contains('Huyện')){
        c.add("d "+x[1].split("Huyện ")[1]);
  }
  else if(x[1].contains('Thành phố')){
        c.add("d "+x[1].split("Thành phố ")[1]);
  }
  else if(x[1].contains('Thị xã')){
        c.add("d "+x[1].split("Thị xã ")[1]);
  }
  else{
    c.add("d "+x[1]);
  }
}

// ignore: public_member_api_docs
Future<List> find_comps(String category,String region,String district,String street,double surface,double width,double length,int toilets,int bedrooms,double price) async{
    Future<List> a=get_street(category,region,district,street);
    List index=[];
    List b = await a;
    List c=[];
    if(b.length >= 20){
      c=rank_point(b, surface, width, length, toilets, bedrooms, price);
      Map x={street:c.length};
      index.add(x);
      if (c.length< 20){
        List d= await get_district(category,region,district);
        print(d.length);
        List e=rank_point2(d, 4, surface, width, length, toilets, bedrooms, price);
        c=c+e;
        List y=haha(e);
        index=index+y;
      }
    }
    else{
      c=b;
      List d= await get_district(category,region,district);
      Map x={street:c.length};
      index.add(x);
      List e=rank_point2(d, 4, surface, width, length, toilets, bedrooms, price);
      List y=haha(e);
      index=index+y;
      c=c + e;      
    }
    print(index);
    print(c.length);
    return [index,c];
}

List rank_point(List b,double surface,double width,double length,int toilets,int bedrooms,double price){
    List c=[];
    for(int i= 0;i<b.length;i++){
      int score=0;
      double b_surface=double.parse(b[i]['surface']);
      var b_price=b[i]['price'];
      double b_width=0;
      if (b[i]['width'].runtimeType==Null){
        b_width=-1;
      }
      else{
        b_width=double.parse(b[i]['width']);
      }
      double b_length=0;
      if (b[i]['length'].runtimeType==Null){
        b_length=-1;
      }
      else{
        b_length=double.parse(b[i]['length']);
      }
      // var b_width=double.parse(b[i]['width']);
      var b_toilets=int.parse(b[i]['toilets']);
      var b_bedrooms=int.parse(b[i]['bedrooms']);
      if(((price/surface)-0.005) <(b_price/b_surface) && (b_price/b_surface)<((price/surface)+0.005)){
        score=score+1;
      }
      if((surface-10) <b_surface && b_surface<(surface+10)){
        score=score+1;
      }
      if((width-2< b_width) && (b_width<width+2)){
        score=score+1;
      }
      if((length-2< b_length) && (b_length<length+2)){
        score=score+1;
      }
      if((toilets-1) < b_toilets && b_toilets<(toilets+1)){
        score=score+1;
      }
      if((bedrooms-1) < b_bedrooms && b_bedrooms<(bedrooms+1)){
        score=score+1;
      }
      if(score > 0){
        c.add(b[i]);
      }
    }
    return c;
}
List rank_point2(List b,int size,double surface,double width,double length,int toilets,int bedrooms,double price){
    List c=[];
    for(int i= 0;i<b.length;i++){
      int score=0;
      double b_surface=double.parse(b[i]['surface']);
      var b_price=b[i]['price'];
      double b_width=-1;
      if (b[i]['width'].runtimeType==Null){
        b_width=-1;
      }
      else{
        b_width=double.parse(b[i]['width']);
      }
      double b_length=0;
      if (b[i]['length'].runtimeType==Null){
        b_length=-1;
      }
      else{
        b_length=double.parse(b[i]['length']);
      }
      // var b_width=double.parse(b[i]['width']);
      var b_toilets=int.parse(b[i]['toilets']);
      var b_bedrooms=int.parse(b[i]['bedrooms']);
      if((price/surface-0.005) <(b_price/b_surface) && (b_price/b_surface)<(price/surface+0.005)){
        score=score+1;
      }
      if((surface-10) <b_surface && b_surface<(surface+10)){
        score=score+1;
      }
      if((width-2< b_width) && (b_width<width+2)){
        score=score+1;
      }
      if((toilets-1) < b_toilets && b_toilets<(toilets+1)){
        score=score+1;
      }
      if((bedrooms-1) < b_bedrooms && b_bedrooms<(bedrooms+1)){
        score=score+1;
      }
      if((length-2< b_length) && (b_length<length+2)){
        score=score+1;
      }
      if(score >= size){
        c.add(b[i]);
      }
    }
    print(c.length);

    return c;
}
List haha(List b){
  List keys=[];
  List values=[];
  for(int i=0;i<b.length;i++){
    if(keys.contains(b[i]['street'])){
      values[keys.indexOf(b[i]['street'])]+=1;
    }
    else{
      keys.add(b[i]['street']);
      values.add(1);
    }  
  }
  List result=[];
  for(int i=0;i<keys.length;i++){
    Map x={keys[i]:values[i]};
    result.add(x);
  }
  return result;
}
void main() async{
    // ignore: omit_local_variable_types

    String testa= "Thành phố Hà Nội > Quận Long Biên";
    List result=[];
    address_split(testa, result);
    print(result);
    List test= await find_comps("nhadat247.com.vn", "Hồ Chí Minh","d Tân Phú","Âu Cơ",75, 6, 12, 3, 3, 24);
    print(test[1][0]);
     // final results = cosmosDB.documents.query(
    //     Query(
    //         query:
    //             'SELECT * FROM c WHERE c.url_hash = "2ec52df92ad3febb70afe776f0a44c2a"'),
    //     'data',
    //     'detail_data',
    //   );
    // print(results);
}