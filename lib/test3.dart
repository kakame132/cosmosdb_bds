import 'dart:ffi';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cosmosdb/cosmosdb.dart';

final cosmosDB = CosmosDB(
  masterKey: '9qu5XzdNZTdCNeC2ZWjWqhZbmWVCoT3qFU0M7SS1P82H00dmG8OSvqEnlEGujIpSUB6lGeyc1Q0ERsDuXirLGg==',
  baseUrl: 'https://synapseliiink.documents.azure.com:443/',
);
// get all documents from a collection
Future<List> get_district(List homepage,String region,String district,String ward,List category) async{
  // final documents = await cosmosDB.documents.list('data', 'detail_data');
  // print(documents);
  var collectionId="final_data";
  var databaseId="data";
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
    String query='';
        for(int i=0;i<condtion.length;i++){
          query=query+condtion[i];
          if(i+1<condtion.length){
            query=query+" and ";
          }
        }
    print(query);
  final results = await cosmosDB.documents.query(
    Query(
        query:
            'SELECT * FROM $collectionId c where c.district=@district and c.region=@region and c.ward=@ward and '+query,
        parameters: {
          'region': region,
          'district': district,
          'ward':ward
        }),
    databaseId ,
    collectionId,
    count
  );
  
    return results.toList();
}
Future<List> get_street(List homepage,String region,String district,String street,List category) async{
  // final documents = await cosmosDB.documents.list('data', 'detail_data');
  // print(documents);
  var collectionId="final_data";
  var databaseId="data";
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
    String query='';
        for(int i=0;i<condtion.length;i++){
          query=query+condtion[i];
          if(i+1<condtion.length){
            query=query+" and ";
          }
        }
    print(query);
  final results = await cosmosDB.documents.query(
    Query(
        query:
            'SELECT * FROM $collectionId c where c.district=@district and c.region=@region and c.street=@street and '+query,
        parameters: {
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
  if (x[0].contains('Th??nh ph???')){
    c.add(x[0].split("Th??nh ph??? ")[1]);
  }
  else if (x[0].contains('T???nh')) {
      c.add(x[0].split("T???nh ")[1]);
  }
  else{
          c.add(x[0]);
  }
  //district
  if (x[1].contains('Qu???n')){
        c.add("d "+x[1].split("Qu???n ")[1]);
  }
  else if(x[1].contains('Huy???n')){
        c.add("d "+x[1].split("Huy???n ")[1]);
  }
  else if(x[1].contains('Th??nh ph???')){
        c.add("d "+x[1].split("Th??nh ph??? ")[1]);
  }
  else if(x[1].contains('Th??? x??')){
        c.add("d "+x[1].split("Th??? x?? ")[1]);
  }
  else{
    c.add("d "+x[1]);
  }
  //ward
  if (x[2].contains('Ph?????ng')){
        c.add(x[2].split("Ph?????ng ")[1]);
  }
  else if(x[2].contains('X??')){
        c.add(x[2].split("X?? ")[1]);
  }
}

// ignore: public_member_api_docs
Future<List> find_comps(List homepage,String region,String district,String ward,String street,List category,double surface,double width,double length,int toilets,int bedrooms,double price) async{
    Future<List> a=get_street(homepage,region,district,street,category);
    List index=[];
    List b = await a;
    List c=[];
    if(b.length >= 20){
      c=rank_point(b, surface, width, length, toilets, bedrooms, price);
      if (c.length< 20){
        List d= await get_district(homepage,region,district,ward,category);
        List e=rank_point2(d, 3, surface, width, length, toilets, bedrooms, price);
        c=c+e;
        List y=haha(c);
        index=index+y;
      }
      else{
        List y=haha(c);
        index=index+y;
      }
    }
    else{
      c=c+b;
      List d= await get_district(homepage,region,district,ward,category);
      List e=rank_point2(d, 3, surface, width, length, toilets, bedrooms, price);
      c=c + e;      
      List y=haha(c);
      index=index+y;
    }
    return index;
}

List rank_point(List b,double surface,double width,double length,int toilets,int bedrooms,double price){
    List c=[];
    for(int i= 0;i<b.length;i++){
      int score=0;
      double b_surface=double.parse(b[i]['surface']);
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
      if(price!=-1){
        var b_price=b[i]['price'];
        if(((price/surface)-0.005) <(b_price/b_surface) && (b_price/b_surface)<((price/surface)+0.005)){
          score=score+1;
        }
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
      if(score > 2){
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
      if(price!=-1){
        var b_price=b[i]['price'];
        if((price/surface-0.005) <(b_price/b_surface) && (b_price/b_surface)<(price/surface+0.005)){
          score=score+1;
        }
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

    return c;
}
List haha(List b){
  List keys=[];
  List values=[];
  for(int i=0;i<b.length;i++){
    if(keys.contains(b[i]['street'])){
      values[keys.indexOf(b[i]['street'])].add(b[i]);
    }
    else{
      keys.add(b[i]['street']);
      List a=[b[i]];
      values.add(a);
    }
  }
  // print(keys.length);
  // print(values[0].runtimeType);
  List result=[];
  for(int i=0;i<keys.length;i++){
    Map x={keys[i]:values[i]};
    result.add(x);
  }
  // print("**********************");
  // print(result[0].values.toList()[0].length);
  // print("**********************");
  return result;
}
void main() async{
    // ignore: omit_local_variable_types

    String testa= "Th??nh ph??? H?? N???i > Qu???n Long Bi??n > Ph?????ng 10";
    List result=[];
    address_split(testa, result);
    List test= await find_comps(["nhadat247.com.vn","chotot.com"], "H??? Ch?? Minh","d 10","15","L?? Th?????ng Ki???t",["nh??"],38, 4, 10, 5, 5, -1);
    //cach lay so luong
    print(test[0].values.toList()[0].length);
    //cach lay list ra theo tung duong
    print(test[0].values.toList()[0]);
    //cach lay tung record ra trong list ra theo tung duong
    print(test[0].values.toList()[0][0]);

}