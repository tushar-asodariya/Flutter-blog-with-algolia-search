const functions = require("firebase-functions");
const admin = require("firebase-admin");
const algoliasearch = require("algoliasearch");

const ALGOLIA_APP_ID = "";
const ALGOLIA_ADMIN_KEY = "";
const ALGOLIA_INDEX_NAME = "users";
var client = algoliasearch(ALGOLIA_APP_ID, ALGOLIA_ADMIN_KEY);
var index = client.initIndex(ALGOLIA_INDEX_NAME);

admin.initializeApp(functions.config().firebase);

exports.setAlgoliaApp = functions.firestore
    .document("BlogDemo/{BlogDemoID}/{allPostCollectionId}/{postId}")
    .onWrite((change, context) => {
        if (!change.before.exists && change.after.exists) {
            
            var blog = change.after.data();
            blog.userId = context.params.BlogDemoID;
            blog.objectID = change.after.id;
            console.log("blog ", blog);
            //index.saveObject(blog);
            index.addObject(blog);
        }
    });

