'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {".git/COMMIT_EDITMSG": "3d46c4975de4d96da57b504aceb5b6c2",
".git/config": "67a322d203f5f544d3777e3115b562c5",
".git/description": "a0a7c3fff21f2aea3cfa1d0316dd816c",
".git/HEAD": "5ab7a4355e4c959b0c5c008f202f51ec",
".git/hooks/applypatch-msg.sample": "ce562e08d8098926a3862fc6e7905199",
".git/hooks/commit-msg.sample": "579a3c1e12a1e74a98169175fb913012",
".git/hooks/fsmonitor-watchman.sample": "a0b2633a2c8e97501610bd3f73da66fc",
".git/hooks/post-update.sample": "2b7ea5cee3c49ff53d41e00785eb974c",
".git/hooks/pre-applypatch.sample": "054f9ffb8bfe04a599751cc757226dda",
".git/hooks/pre-commit.sample": "5029bfab85b1c39281aa9697379ea444",
".git/hooks/pre-merge-commit.sample": "39cb268e2a85d436b9eb6f47614c3cbc",
".git/hooks/pre-push.sample": "2c642152299a94e05ea26eae11993b13",
".git/hooks/pre-rebase.sample": "56e45f2bcbc8226d2b4200f7c46371bf",
".git/hooks/pre-receive.sample": "2ad18ec82c20af7b5926ed9cea6aeedd",
".git/hooks/prepare-commit-msg.sample": "2b5c047bdb474555e1787db32b2d2fc5",
".git/hooks/push-to-checkout.sample": "c7ab00c7784efeadad3ae9b228d4b4db",
".git/hooks/sendemail-validate.sample": "4d67df3a8d5c98cb8565c07e42be0b04",
".git/hooks/update.sample": "647ae13c682f7827c22f5fc08a03674e",
".git/index": "005d0c607888b3df456fd18f651453cc",
".git/info/exclude": "036208b4a1ab4a235d75c181e685e5a3",
".git/logs/HEAD": "141e866d3c959fefca4bb0c407669519",
".git/logs/refs/heads/gh-pages": "2ec606e670c2d8500727ecdd054a13de",
".git/logs/refs/remotes/origin/gh-pages": "9e9158425e6f3b07b4d54ab8a01c6901",
".git/objects/05/9efdbdae343f3dcaf57a6387a93144f542bc89": "f34e176661c0393ba52c320bc7ec4f7a",
".git/objects/06/6d82143b87e8d022f13e46563a464cd2021eb3": "2521507ebf9e4d7adb832cf91311e106",
".git/objects/08/27c17254fd3959af211aaf91a82d3b9a804c2f": "360dc8df65dabbf4e7f858711c46cc09",
".git/objects/0e/a26889ba8898af689d63f70059c4c85f753e93": "3d9d30c2592cc4c9554d145bbfbb2e19",
".git/objects/11/ac05fbda1efc8a7172d2fe413241dd0193c409": "34397206e82e7fff4af82fc13fba23f2",
".git/objects/15/f1a2e62fd352d65310881a6c609b3bb64e1548": "55795e373ef20691ec9a01a1942034d6",
".git/objects/18/6ad631a85cf4dfc3ff44885828da69d88c60f2": "ae2e51263bd0d47e107fd91229c85551",
".git/objects/2e/17ae4b70f41ac343a48ed0add5a60880e603bb": "fb124d30e83f32dab109470908cd02a6",
".git/objects/37/3125335d04015b17ecc07e23f91fe51c9f0c6c": "d042d980fefdc52d2b8303bb7b010931",
".git/objects/3a/8cda5335b4b2a108123194b84df133bac91b23": "1636ee51263ed072c69e4e3b8d14f339",
".git/objects/46/4ab5882a2234c39b1a4dbad5feba0954478155": "2e52a767dc04391de7b4d0beb32e7fc4",
".git/objects/50/73b8c6894622195f6587549547d22c19a178ab": "bc6d95f3f14d919ad55a0d3217244319",
".git/objects/51/03e757c71f2abfd2269054a790f775ec61ffa4": "d437b77e41df8fcc0c0e99f143adc093",
".git/objects/52/b8a5aca7ac54eeb7c6db843a930d0e6c7a7d1e": "01fb55cf4530054c1d34329e37d3c25e",
".git/objects/56/fe59a58fbb9f72878c5d5b4bbb67845eb81dac": "8d8082c9019bdebd0a365fc7f44e125d",
".git/objects/5d/b8506c1e26ab8845943525337353acbb3cf428": "86bcd9b84e23dff6b8a8d5abb9c67679",
".git/objects/66/200d34083447bb25da682b2a805fb0b1a055fc": "75eff074e48c1b32dee308559e3b025a",
".git/objects/68/43fddc6aef172d5576ecce56160b1c73bc0f85": "2a91c358adf65703ab820ee54e7aff37",
".git/objects/6b/9862a1351012dc0f337c9ee5067ed3dbfbb439": "85896cd5fba127825eb58df13dfac82b",
".git/objects/6e/6f26b17a9c3e664fd6712466eb0d41ac407af9": "7bc23df98585a8334f80405f7c230d97",
".git/objects/6f/7661bc79baa113f478e9a717e0c4959a3f3d27": "985be3a6935e9d31febd5205a9e04c4e",
".git/objects/71/8f01752e0a0cb00f1e4be14aed2ab9155783f1": "1f8dd06b8ba0b0991baae3d9837bf2b3",
".git/objects/7c/3463b788d022128d17b29072564326f1fd8819": "37fee507a59e935fc85169a822943ba2",
".git/objects/7e/83a96dc9edef3742385960de61e59501dd3e85": "450e7db1b0d13f4a40dfd260145b1d9d",
".git/objects/80/8355d570989c4570b82b613ec9815b0c61b432": "e927bc2308cb805035957e5f32e3ab16",
".git/objects/85/63aed2175379d2e75ec05ec0373a302730b6ad": "997f96db42b2dde7c208b10d023a5a8e",
".git/objects/88/cfd48dff1169879ba46840804b412fe02fefd6": "e42aaae6a4cbfbc9f6326f1fa9e3380c",
".git/objects/8a/aa46ac1ae21512746f852a42ba87e4165dfdd1": "1d8820d345e38b30de033aa4b5a23e7b",
".git/objects/8e/21753cdb204192a414b235db41da6a8446c8b4": "1e467e19cabb5d3d38b8fe200c37479e",
".git/objects/91/372e7173b6cce7eca6e1111c69da04f79f4dc8": "b8ed27c07fcec55aaea24b7b472ab951",
".git/objects/92/895cbbd73fff8a60d412c8922ec08b52f0c31f": "5b5196b24c310da9b9d63d5fc5f4c689",
".git/objects/93/b363f37b4951e6c5b9e1932ed169c9928b1e90": "c8d74fb3083c0dc39be8cff78a1d4dd5",
".git/objects/97/e966d061493ae7e3f7658c4f6d09dbc01dbef1": "4982ddd593a9c809b83be8ae61b6f884",
".git/objects/9a/860a3c0d65720c9edbbea8bbf6520bd1054e4c": "f29b6a71224d50b0babc2400d1416d35",
".git/objects/a7/3f4b23dde68ce5a05ce4c658ccd690c7f707ec": "ee275830276a88bac752feff80ed6470",
".git/objects/ad/ced61befd6b9d30829511317b07b72e66918a1": "37e7fcca73f0b6930673b256fac467ae",
".git/objects/b7/49bfef07473333cf1dd31e9eed89862a5d52aa": "36b4020dca303986cad10924774fb5dc",
".git/objects/b9/2a0d854da9a8f73216c4a0ef07a0f0a44e4373": "f62d1eb7f51165e2a6d2ef1921f976f3",
".git/objects/b9/3e39bd49dfaf9e225bb598cd9644f833badd9a": "666b0d595ebbcc37f0c7b61220c18864",
".git/objects/c0/5d6550d56f659df0cf7bdf78d483c3a8ec5f42": "b0330f69081377cff2aebd857bfbd366",
".git/objects/c8/3af99da428c63c1f82efdcd11c8d5297bddb04": "144ef6d9a8ff9a753d6e3b9573d5242f",
".git/objects/d4/3532a2348cc9c26053ddb5802f0e5d4b8abc05": "3dad9b209346b1723bb2cc68e7e42a44",
".git/objects/d6/3a150f8f69d20b1f34062a367be6b779537a47": "e6c6b463718d68eb51fb4e25fe7aeed4",
".git/objects/d6/9c56691fbdb0b7efa65097c7cc1edac12a6d3e": "868ce37a3a78b0606713733248a2f579",
".git/objects/d7/7cfefdbe249b8bf90ce8244ed8fc1732fe8f73": "9c0876641083076714600718b0dab097",
".git/objects/d9/5b1d3499b3b3d3989fa2a461151ba2abd92a07": "a072a09ac2efe43c8d49b7356317e52e",
".git/objects/e2/31708fd7b39cd7b0ce1fbc1823bec5f8ecf07d": "aab8f41d577618af368eebc331228390",
".git/objects/e7/734752d3f92e55c21ebebd8f2b21c3b61cf20f": "6e2e2bdcbb287feee7e08def92c11303",
".git/objects/e9/94225c71c957162e2dcc06abe8295e482f93a2": "2eed33506ed70a5848a0b06f5b754f2c",
".git/objects/eb/9b4d76e525556d5d89141648c724331630325d": "37c0954235cbe27c4d93e74fe9a578ef",
".git/objects/ec/1cca4564a8740fdf20339d63fff2face82354a": "65aa247270ded96c3f3ba8e16f8de854",
".git/objects/f0/2580196c6e6a1191f0e469a7f1f1ed5ccc352d": "afccd64487e44825104ac63d53e3d213",
".git/objects/f3/3e0726c3581f96c51f862cf61120af36599a32": "afcaefd94c5f13d3da610e0defa27e50",
".git/objects/f5/72b90ef57ee79b82dd846c6871359a7cb10404": "e68f5265f0bb82d792ff536dcb99d803",
".git/objects/f6/e6c75d6f1151eeb165a90f04b4d99effa41e83": "95ea83d65d44e4c524c6d51286406ac8",
".git/objects/fb/ab5ce163af3c16587356adadeb717b12b2dc4b": "46404aa98b0f416291aecf14568d790a",
".git/objects/fd/05cfbc927a4fedcbe4d6d4b62e2c1ed8918f26": "5675c69555d005a1a244cc8ba90a402c",
".git/objects/ff/1127e9d16849386eb4a7ed50544b02234ce0d2": "fb5d0dfd5439d25a4b79ebcb2eef953d",
".git/objects/ff/a15ea4fcefdb39d22fdaff7f6d94ea8437a14b": "5d909dfd7143b7ae7f4381d7e039709a",
".git/objects/ff/c3649592b23252e7cc2600a95559ab226b4f64": "12b6270cead54c7950a0ac50be7bb02a",
".git/refs/heads/gh-pages": "21260f4001bdafbff55582dfbec41fe0",
".git/refs/remotes/origin/gh-pages": "21260f4001bdafbff55582dfbec41fe0",
"assets/AssetManifest.bin": "c8accd0c377623fd22a1108e04a96037",
"assets/AssetManifest.bin.json": "a44e824cae96fea55e1c1470c0add5c1",
"assets/assets/images/farmers_register_page.png": "4e3d0652594fb5268deb159a1610c307",
"assets/assets/images/home_page.png": "3a8a5bc042691e2a1bedc1152253382a",
"assets/assets/images/logo.png": "7cb571a72d014779df070ae7a264aa80",
"assets/assets/images/logo1.png": "9e434639c1e89296340e438d65f6c083",
"assets/assets/images/product_page.png": "3b7a12d242b160bc80442f0447e44fb2",
"assets/assets/images/repayement_page.png": "0801ca1f51d15ac27378f9e8b1af2570",
"assets/assets/images/rist.png": "649a066f33bfe1742c567ded72c18133",
"assets/assets/images/search_page.png": "09205e432cc9390f7ccd9c57aa31f3e9",
"assets/assets/images/splash_screen.png": "6690e96c451adfdbecd184de63b3d9da",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "e60d93f5867f14e2515043707f456973",
"assets/NOTICES": "f67176d77d2d229966d67b6c3a53d567",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/shaders/stretch_effect.frag": "40d68efbbf360632f614c731219e95f0",
"canvaskit/canvaskit.js": "8331fe38e66b3a898c4f37648aaf7ee2",
"canvaskit/canvaskit.js.symbols": "a3c9f77715b642d0437d9c275caba91e",
"canvaskit/canvaskit.wasm": "9b6a7830bf26959b200594729d73538e",
"canvaskit/chromium/canvaskit.js": "a80c765aaa8af8645c9fb1aae53f9abf",
"canvaskit/chromium/canvaskit.js.symbols": "e2d09f0e434bc118bf67dae526737d07",
"canvaskit/chromium/canvaskit.wasm": "a726e3f75a84fcdf495a15817c63a35d",
"canvaskit/skwasm.js": "8060d46e9a4901ca9991edd3a26be4f0",
"canvaskit/skwasm.js.symbols": "3a4aadf4e8141f284bd524976b1d6bdc",
"canvaskit/skwasm.wasm": "7e5f3afdd3b0747a1fd4517cea239898",
"canvaskit/skwasm_heavy.js": "740d43a6b8240ef9e23eed8c48840da4",
"canvaskit/skwasm_heavy.js.symbols": "0755b4fb399918388d71b59ad390b055",
"canvaskit/skwasm_heavy.wasm": "b0be7910760d205ea4e011458df6ee01",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "24bc71911b75b5f8135c949e27a2984e",
"flutter_bootstrap.js": "c834bc5d2a9008f6c1a92e39bb749bd2",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "f087f6c9be938d1a2bec100ca1010464",
"/": "f087f6c9be938d1a2bec100ca1010464",
"main.dart.js": "78e22a6b5ed7de31114ce2cfe89d7a3a",
"manifest.json": "b8f4ae59b49bdbcbd6375414be3dead3",
"version.json": "61ebb18c1134cd69398097e3a899ffc0"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
