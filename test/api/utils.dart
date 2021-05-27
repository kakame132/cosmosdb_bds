// Copyright 2021 Jonas Franz
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:math';

import 'package:cosmosdb/cosmosdb.dart';
import 'package:crypto/crypto.dart';
import 'package:http/io_client.dart';
import 'package:universal_io/io.dart';

import 'test_config.dart';

String generateId() {
  final random = Random();
  var values = List<int>.generate(32, (i) => random.nextInt(256));
  return md5.convert(values).toString();
}

CosmosDB buildClient() {
  final client = HttpClient();
  if (TestConfig.ignoreSelfSignedCertificates) {
    client.badCertificateCallback = (_, __, ___) => true;
  }
  return CosmosDB(
    masterKey: TestConfig.cosmosDBMasterKey,
    baseUrl: TestConfig.cosmosDBUrl,
    httpClient: IOClient(client),
  );
}
