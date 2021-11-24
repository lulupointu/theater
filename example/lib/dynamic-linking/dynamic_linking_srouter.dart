// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:srouter/src/route/s_route_interface.dart';
import 'package:srouter/srouter.dart';

void main() {
  initializeSRouter();

  runApp(WishlistApp());
}

class Wishlist {
  final String id;

  Wishlist(this.id);
}

class WishlistApp extends StatefulWidget {
  @override
  State<WishlistApp> createState() => _WishlistAppState();
}

class _WishlistAppState extends State<WishlistApp> {
  final List<Wishlist> wishlists = [];

  void toWishlist(BuildContext context, Wishlist wishlist) {
    _addWishlistIfNotPresent(wishlist);
    context.sRouter.push(
      WishlistSRoute(wishlists: wishlists, wishlist: wishlist, toWishlist: toWishlist),
    );
  }

  void _addWishlistIfNotPresent(Wishlist wishlist) {
    if (!wishlists.any((e) => e.id == wishlist.id)) wishlists.add(wishlist);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Books App',
      home: SRouter(
        initialRoute: WishlistListSRoute(wishlists: [], toWishlist: toWishlist),
        translatorsBuilder: (_) => [
          SPathTranslator<WishlistListSRoute, SPushable>.static(
            path: '/',
            route: WishlistListSRoute(wishlists: wishlists, toWishlist: toWishlist),
          ),
          SPathTranslator<WishlistSRoute, SPushable>(
            path: '/wishlist/:id',
            matchToRoute: (match) {
              final wishlist = Wishlist(match.pathParams['id']!);
              _addWishlistIfNotPresent(wishlist);
              return WishlistSRoute(
                  wishlists: wishlists, wishlist: wishlist, toWishlist: toWishlist);
            },
            routeToWebEntry: (route) => WebEntry(path: '/wishlist/${route.wishlist.id}'),
          ),
          SRedirectorTranslator.static(
            from: '*',
            to: WishlistListSRoute(wishlists: [], toWishlist: toWishlist),
          ),
        ],
      ),
    );
  }
}

class WishlistListSRoute extends SRoute<SPushable> {
  final List<Wishlist> wishlists;
  final void Function(BuildContext context, Wishlist wishlist) toWishlist;

  WishlistListSRoute({required this.wishlists, required this.toWishlist});

  @override
  Widget build(BuildContext context) {
    return WishlistListScreen(wishlists: wishlists, toWishlist: toWishlist);
  }
}

class WishlistSRoute extends SRoute<SPushable> {
  final List<Wishlist> wishlists;
  final Wishlist wishlist;
  final void Function(BuildContext context, Wishlist wishlist) toWishlist;

  WishlistSRoute({required this.wishlists, required this.wishlist, required this.toWishlist});

  @override
  Widget build(BuildContext context) => WishlistScreen(wishlist: wishlist);

  @override
  SRouteInterface<SPushable> buildSRouteBellow(BuildContext context) {
    return WishlistListSRoute(wishlists: wishlists, toWishlist: toWishlist);
  }
}

class WishlistListScreen extends StatelessWidget {
  final List<Wishlist> wishlists;
  final void Function(BuildContext context, Wishlist wishlist) toWishlist;

  WishlistListScreen({required this.wishlists, required this.toWishlist});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Navigate to /wishlist/<ID> in the URL bar to dynamically '
                'create a new wishlist.'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () => toWishlist(context, Wishlist('${Random().nextInt(10000)}')),
              child: Text('Create a new Wishlist'),
            ),
          ),
          for (var i = 0; i < wishlists.length; i++)
            ListTile(
              title: Text('Wishlist ${i + 1}'),
              subtitle: Text(wishlists[i].id),
              onTap: () => toWishlist(context, wishlists[i]),
            )
        ],
      ),
    );
  }
}

class WishlistScreen extends StatelessWidget {
  final Wishlist wishlist;

  WishlistScreen({
    required this.wishlist,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${wishlist.id}', style: Theme.of(context).textTheme.headline6),
          ],
        ),
      ),
    );
  }
}
