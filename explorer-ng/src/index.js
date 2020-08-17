const { MongoClient } = require("mongodb");

// Replace the uri string with your MongoDB deployment's connection string.
// mongodb://127.0.0.1:27017/?compressors=disabled&gssapiServiceName=mongodb
const uri = "mongodb://127.0.0.1:27017/?compressors=zlib&gssapiServiceName=mongodb"

const client = new MongoClient(uri);

async function run() {
  try {
    await client.connect();

    const database = client.db('explorer');
    const collection = database.collection('accounts');

    // Query for a movie that has the title 'Back to the Future'
    const query = { name: 'account0058' };
    const accounts = await collection.findOne(query);

    console.log(accounts);
  } finally {
    // Ensures that the client will close when you finish/error
    await client.close();
  }
}
run().catch(console.dir);

// > show collections
// accountPubkey
// accountTx
// accounts
// blocks
// contractTx
// contracts
// txs
// voteTx
//
// {
//	"_id" : ObjectId("5f398cbaddaec5ccc6ccd56a"),
//	"name" : "account0058",
//	"createTime" : NumberLong("1597292419500474104"),
//	"creator" : "admin",
//	"accountInfo" : {
//		"name" : "account0058",
//		"balance" : 998866.67,
//		"gasinfo" : {
//			"currenttotal" : 300003000000,
//			"transferablegas" : 0,
//			"pledgegas" : 300003000000,
//			"increasespeed" : 1150011.5,
//			"limit" : 300003000000,
//			"pledgedinfo" : [ ],
//			"xxx_nounkeyedliteral" : {
//
//			},
//			"xxx_unrecognized" : BinData(0,""),
//			"xxx_sizecache" : 0
//		},
//		"raminfo" : {
//			"available" : NumberLong(1000000),
//			"used" : NumberLong(0),
//			"total" : NumberLong(1000000),
//			"xxx_nounkeyedliteral" : {
//
//			},
//			"xxx_unrecognized" : BinData(0,""),
//			"xxx_sizecache" : 0
//		},
//		"permissions" : {
//			"active" : {
//				"name" : "active",
//				"groupnames" : [ ],
//				"items" : [
//					{
//						"id" : "GF1bE7tZydYrkk9rKMLhicHF3kzQyaM54m1WGu1dmkCL",
//						"iskeypair" : true,
//						"weight" : NumberLong(100),
//						"permission" : "",
//						"xxx_nounkeyedliteral" : {
//
//						},
//						"xxx_unrecognized" : BinData(0,""),
//						"xxx_sizecache" : 0
//					}
//				],
//				"threshold" : NumberLong(100),
//				"xxx_nounkeyedliteral" : {
//
//				},
//				"xxx_unrecognized" : BinData(0,""),
//				"xxx_sizecache" : 0
//			},
//			"owner" : {
//				"name" : "owner",
//				"groupnames" : [ ],
//				"items" : [
//					{
//						"id" : "GF1bE7tZydYrkk9rKMLhicHF3kzQyaM54m1WGu1dmkCL",
//						"iskeypair" : true,
//						"weight" : NumberLong(100),
//						"permission" : "",
//						"xxx_nounkeyedliteral" : {
//
//						},
//						"xxx_unrecognized" : BinData(0,""),
//						"xxx_sizecache" : 0
//					}
//				],
//				"threshold" : NumberLong(100),
//				"xxx_nounkeyedliteral" : {
//
//				},
//				"xxx_unrecognized" : BinData(0,""),
//				"xxx_sizecache" : 0
//			}
//		},
//		"groups" : {
//
//		},
//		"frozenbalances" : [ ],
//		"xxx_nounkeyedliteral" : {
//
//		},
//		"xxx_unrecognized" : BinData(0,""),
//		"xxx_sizecache" : 0
//	}
//}
