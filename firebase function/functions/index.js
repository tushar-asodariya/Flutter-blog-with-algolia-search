const functions = require("firebase-functions");
const admin = require("firebase-admin");
const algoliasearch = require("algoliasearch");

const ALGOLIA_APP_ID = "TSHPKTI8ZT";
const ALGOLIA_ADMIN_KEY = "27860b3ede68339dcf24b595862ef95d";
const ALGOLIA_INDEX_NAME = "users";
var client = algoliasearch(ALGOLIA_APP_ID, ALGOLIA_ADMIN_KEY);
var index = client.initIndex(ALGOLIA_INDEX_NAME);

admin.initializeApp(functions.config().firebase);

exports.setAlgoliaApp = functions.firestore
    .document("BlogDemo/{BlogDemoID}/{allPostCollectionId}/{postId}")
    .onWrite((change, context) => {
        if (!change.before.exists && change.after.exists) {
            // Retrieves all attributes
            //index.getObject(context.params.BlogDemoID, (err, content) => {
            //  console.log(content);
            // });
            var blog = change.after.data();
            blog.userId = context.params.BlogDemoID;
            blog.objectID = change.after.id;
            console.log("blog ", blog);
            //index.saveObject(blog);
            index.addObject(blog);
        }
    });

/*let records = [];
let querySnapshot = admin.firestore()
    .collection('BlogDemo').get();

for (let i in querySnapshot.docs) {
    let obj = querySnapshot.docs[i].data();
    obj.objectID = querySnapshot.docs[i].id;
    records.push(obj);

}

index.saveObjects(records);


exports.addFirestoreDataToAlgolia = functions.https.onRequest((req, res) => {
    var arr = [];

    admin
        .firestore()
        .collection("BlogDemo")
        .get()
        .then(docs => {
            docs.forEach(doc => {
                let user = doc.data();
                console.log(user);
                user.objectID = doc.id;

                arr.push(user);
            });

            index.saveObjects(arr, function(err, content) {
                res.status(200).send(content);
            });
        });
});
*/