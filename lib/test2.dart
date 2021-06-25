import 'dart:ffi';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cosmosdb/cosmosdb.dart';

final cosmosDB = CosmosDB(
  masterKey: 'NivTYKZvt56pqDRtq7lQCJJ7Xs7nCo2RzPkOkAkHjUygx3D0dqAHfGF4edxoJFXSOvCzOkwF1PFoGqgYMnFrfw==',
  baseUrl: 'https://synapselynk1.documents.azure.com:443/',
);
// get all documents from a collection
Future<List> get_config(String model) async{
  // final documents = await cosmosDB.documents.list('data', 'detail_data');
  // print(documents);
  var collectionId="config";
  var databaseId="data";
  String count="100";
  final results = await cosmosDB.documents.query(
    Query(
        query:
            'SELECT * FROM $collectionId c where c.model=@model',
        parameters: {
          'model': model
        }),
    databaseId ,
    collectionId,
    count
  );
  
  Map index_dict=jsonDecode(results.toList().last['list']);
  int size=results.toList().last['size'];
  // return a;
  // print(jsonDecode(a));
  return [size,index_dict];
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

void predict(String type,Map index,int size,String category,String region,String district,double surface,double width,double length,int toilets,int bedrooms) async{
    List output = List.filled(size,0);
    output[index['surface']] = surface;
    output[index['width']] = width;
    output[index['length']] = length;
    output[index['toilets']] = toilets;
    output[index['bedrooms']] = bedrooms; 
    if (index.keys.contains(category)){
          output[index[category]]=1;}
    String result_district = district;
    if (index.keys.contains(result_district)){
          print(1999);
          output[index[district]] = 1;}
    else{
        print(1);
        output[index['other_district']] = 1;}
    String result_region = region;
    if (index.keys.contains(result_region)){
          print(2999);
          output[index[region]] = 1;}
    else{
          print(2);
          output[index['other_region']]=1;}
    String input_data = json.encode({'data': [output.toList()]});
    Map headers = {'Content-Type': 'application/json'};
    String scoring_uri="";
    if(type=="chotot"){
    scoring_uri = "http://c28e5a9c-af76-4695-8e15-9d88c226ecad.eastus2.azurecontainer.io/score";
    }
    else if(type=="main"){
    scoring_uri="http://be4e6aa3-74df-44ba-98c1-cfb1c4e12ac5.eastus2.azurecontainer.io/score";
    }
    else if(type=="nhadat247"){
    scoring_uri="http://09cb0d7d-d772-4846-9c58-ec3553d964d4.eastus2.azurecontainer.io/score";
    }
    else if(type=="batdongsan"){
    scoring_uri="http://5de8edf8-3a7c-402b-9758-20d5616c34b4.eastus2.azurecontainer.io/score";
    }
    http.Response response = await http.post(
    Uri.parse(scoring_uri),
    headers: {"Content-Type": "application/json"},
    body: input_data,);
    print(response.body);
    // scoring_uri = "http://3b3ce046-1670-45e1-9300-172a430172a1.eastus2.azurecontainer.io/score"
    // resp = requests.post(scoring_uri, input_data, headers=headers)

    // return resp.text
}
void main() async{
    // ignore: omit_local_variable_types
    List a= await get_config("main");
    int main_size=a[0];
    Map main_dict=a[1];
    List b= await get_config("chotot");
    int chotot_size=b[0];
    Map chotot_dict=b[1];
    
    List c= await get_config("nhadat247");
    int nhadat_size=c[0];
    Map nhadat_dict=c[1];
    List d= await get_config("batdongsan");
    int batdongsan_size=d[0];

    Map batdongsan_dict=d[1];
    

    String testa= "Thành phố Hà Nội > Quận Long Biên";
    List result=[];
    address_split(testa, result);
    print(result);

    predict("main",main_dict, main_size,"nhà",'Hà Nội','d Long Biên', 33, 4,8,3,4);
    predict("chotot",chotot_dict, chotot_size,"nhà",'Hà Nội','d Long Biên', 33, 4,8,3,4);
    predict("nhadat247",nhadat_dict, nhadat_size,"nhà",'Hà Nội','d Long Biên', 33, 4,8,3,4);
    predict("batdongsan",batdongsan_dict, batdongsan_size,"nhà",'Hà Nội','d Long Biên', 33, 4,8,3,4);

     // final results = cosmosDB.documents.query(
    //     Query(
    //         query:
    //             'SELECT * FROM c WHERE c.url_hash = "2ec52df92ad3febb70afe776f0a44c2a"'),
    //     'data',
    //     'detail_data',
    //   );
    // print(results);
}