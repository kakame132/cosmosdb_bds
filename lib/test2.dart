import 'dart:ffi';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cosmosdb/cosmosdb.dart';

final cosmosDB = CosmosDB(
  masterKey: 'OWypOh21j1xVTQtjCtVq7KgTmG95vEdWGlOUPa90MvVEHSfrkrHBE9IYTEjz97SwMRAVXgG8a5y9vGdCoxKakg==',
  baseUrl: 'https://synapselynk2.documents.azure.com:443/',
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
            'SELECT * FROM $collectionId c where c.name=@model',
        parameters: {
          'model': model
        }),
    databaseId ,
    collectionId,
    count
  );
  
  Map index_dict=jsonDecode(results.toList().last['list']);
  // return a;
  // print(jsonDecode(a));
  return [index_dict];
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

void predict(String type,Map index,String category,String region,String district,double surface,double width,double length,int toilets,int bedrooms) async{
    
    String result_district = district;
    int input_district=0;
    if (index.keys.contains(result_district)){
          input_district=index[district];}
    
    String input_data = json.encode({
    "data":
    [
        {
            'surface': surface,
            'bedrooms': bedrooms,
            'toilets': toilets,
            'district': input_district,
            'length': length,
            'width': width,
        },
    ],
});
    Map headers = {'Content-Type': 'application/json'};
    String scoring_uri="";
    if(type=="chotot"){
    scoring_uri = "http://c17c7863-1b0c-4c01-94ea-351625a7f432.westus.azurecontainer.io/score";
    }
    else if(type=="main"){
    scoring_uri="http://ce68225d-d583-41f6-a6d2-50b0190f91d1.westus.azurecontainer.io/score";
    }
    else if(type=="nhadat247"){
    scoring_uri="http://70161814-5433-412c-864d-82dc7e8eb9a9.westus.azurecontainer.io/score";
    }
    else if(type=="batdongsan"){
    scoring_uri="http://082d7396-d444-4895-a4d4-7fc0cf8dc096.westus.azurecontainer.io/score";
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
    List a= await get_config("region");
    Map region_dict=a[0];
    List b= await get_config("district");
    Map district_dict=b[0];
    List c= await get_config("category");
    Map category_dict=c[0];
    // List b= await get_config("chotot");
    // int chotot_size=b[0];
    // Map chotot_dict=b[1];
    
    // List c= await get_config("nhadat247");
    // int nhadat_size=c[0];
    // Map nhadat_dict=c[1];
    // List d= await get_config("batdongsan");
    // int batdongsan_size=d[0];

    // Map batdongsan_dict=d[1];
    

    // String testa= "Thành phố Hà Nội > Quận Long Biên";
    // List result=[];
    // address_split(testa, result);
    // print(result);

    predict("main",district_dict,"nhà",'Hà Nội','d Long Biên', 33, 4,8,3,4);
    predict("chotot",district_dict,"nhà",'Hà Nội','d Long Biên', 33, 4,8,3,4);
    predict("nhadat247",district_dict,"nhà",'Hà Nội','d Long Biên', 33, 4,8,3,4);
    predict("batdongsan",district_dict,"nhà",'Hà Nội','d Long Biên', 35, 4,8,10,4);

     // final results = cosmosDB.documents.query(
    //     Query(
    //         query:
    //             'SELECT * FROM c WHERE c.url_hash = "2ec52df92ad3febb70afe776f0a44c2a"'),
    //     'data',
    //     'detail_data',
    //   );
    // print(results);
}