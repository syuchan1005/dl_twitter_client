import 'package:dl_twitter/Consts.dart';
import 'package:dl_twitter/StatusCard.dart';
import 'package:flutter/material.dart';

import 'package:graphql_flutter/graphql_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final HttpLink httpLink = HttpLink(
      uri: '$host$graphqlPath',
    );

    ValueNotifier<GraphQLClient> client = ValueNotifier(
      GraphQLClient(
        cache: InMemoryCache(),
        link: httpLink,
      ),
    );

    return GraphQLProvider(
        client: client,
        child: CacheProvider(
          child: MaterialApp(
            title: 'DL Twitter',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              accentColor: Colors.pinkAccent,
            ),
            home: MyHomePage(title: 'DL Twitter'),
          ),
        ));
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _tweetId = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          Query(
            options: QueryOptions(
              documentNode: gql("""{
              statuses {
                id
                text
                createdAt
                deletedAt
                user {
                  id
                  name
                  screenName
                }
                media {
                  id
                  type
                  url
                  ext
                  createdAt
                }
              }
            }"""),
              pollInterval: 10,
            ),
            builder: (QueryResult result,
                {VoidCallback refetch, FetchMore fetchMore}) {
              if (result.hasException) return Text(result.exception.toString());
              if (result.loading) return Text('Loading');
              List statuses = result.data['statuses'];
              return Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Expanded(
                        child: RefreshIndicator(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemBuilder: (context, index) => StatusCard(
                              key: ValueKey(statuses[index]['id']),
                              status: statuses[index],
                            ),
                            itemCount: statuses.length,
                          ),
                          onRefresh: refetch,
                        ),
                    ),
                  ],
                ),
              );
            },
          ),
          /*
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) => Text('$index'),
              itemCount: 100,
              shrinkWrap: true,
            ),
          ),
          */
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        tooltip: 'add tweet',
        onPressed: () {
          showDialog(
              context: context,
              builder: (_) {
                return AlertDialog(
                  title: Text('Add save tweet'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Status ID',
                        ),
                        onChanged: (String e) {
                          setState(() {
                            _tweetId = e;
                          });
                        },
                      ),
                    ],
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('Cancel'),
                      textColor: Theme.of(context).accentColor,
                      onPressed: () => Navigator.pop(context),
                    ),
                    Mutation(
                      options: MutationOptions(
                        documentNode: gql("""mutation(\$id: ID!) {
                       saveTweet(id: \$id) {
                         success
                       }
                     }"""),
                        onCompleted: (data) {
                          Navigator.pop(context);
                        },
                      ),
                      builder: (RunMutation runMutation, QueryResult result) {
                        return FlatButton(
                          child: Text('Add'),
                          onPressed: () => runMutation({
                            'id': _tweetId,
                          }),
                        );
                      },
                    ),
                  ],
                );
              });
        },
      ),
    );
  }
}
