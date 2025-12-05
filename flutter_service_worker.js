'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter.js": "24bc71911b75b5f8135c949e27a2984e",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"manifest.json": "7f32e8e5f8295d18071a2b92f7916c41",
"index.html": "32494d83b3bc396fb2d46fc7ba890d43",
"/": "32494d83b3bc396fb2d46fc7ba890d43",
"assets/shaders/stretch_effect.frag": "40d68efbbf360632f614c731219e95f0",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin.json": "b2bfcfa5c757240ed983e4ee73116eb5",
"assets/assets/empty_bowl.png": "7fff0e0d37ded790aa0d5e4b3fe49b71",
"assets/assets/sister_standing.png": "f34e4f6849eb6f813ed9958e963da333",
"assets/assets/kindle.png-autosave.kra": "878f1c5919fdc0466fa1cbc2f98f2857",
"assets/assets/popcorn_maker.png": "78ef477cc90bfc3dfbbb5090f36ce583",
"assets/assets/sister_sitting_couch.png": "2b0a34235899643208ea6a57a2f922ec",
"assets/assets/popcorn_seeds.png": "784272287eb5d1d9e6ec07b2c49b2936",
"assets/assets/images/makeup/bubble.png": "445ad8793bafe157e8a136532bd27d0d",
"assets/assets/images/makeup/icon_clean.png": "ec6776bd91203b8dea5844768840f4e1",
"assets/assets/images/makeup/face_masked.png": "e76a1322ddb612d1157d137d621dcd62",
"assets/assets/images/makeup/face_excited.png": "64de5ac863ab7fea93127f523b1c7aa4",
"assets/assets/images/makeup/icon_pump.png": "ec6776bd91203b8dea5844768840f4e1",
"assets/assets/images/makeup/arrow_left.png": "52d6d0ab07d8179ceceb8d777ed86bbd",
"assets/assets/images/makeup/face_neutral.png": "36a70c7c84a1e7226adbe8cd336a0cce",
"assets/assets/images/makeup/zit.png": "4e0abe216dc555907a90f94d2d6f8cfd",
"assets/assets/images/makeup/face_happy.png": "7ca9be48581b4a5c8ad91e5485f19eba",
"assets/assets/images/makeup/face_relaxed.png": "36a70c7c84a1e7226adbe8cd336a0cce",
"assets/assets/images/makeup/face_with_cucumbers.png": "e76a1322ddb612d1157d137d621dcd62",
"assets/assets/images/makeup/arrow_right.png": "52d6d0ab07d8179ceceb8d777ed86bbd",
"assets/assets/images/makeup/icon_apply.png": "ec6776bd91203b8dea5844768840f4e1",
"assets/assets/images/makeup/zit_popped.png": "8ff801e0656c86fa7247ee56b6a15ac3",
"assets/assets/images/makeup/product_spray.png": "20175324865ae847ffd5f433b49c1557",
"assets/assets/images/makeup/icon_glow.png": "ec6776bd91203b8dea5844768840f4e1",
"assets/assets/images/makeup/icon_mask.png": "ec6776bd91203b8dea5844768840f4e1",
"assets/assets/images/makeup/hand_point.png": "cc3e586f90e4c183faf39f65bf80f148",
"assets/assets/images/makeup/face_scared.png": "c64a28c44fdc878a5284199fa1939275",
"assets/assets/images/makeup/crown.png": "cad00041fb698068c77073cc36f693a9",
"assets/assets/images/makeup/cucumber.png": "a2be853d21d3cd7c2d26ebdfc7a9d2a1",
"assets/assets/images/makeup/icon_pop.png": "ec6776bd91203b8dea5844768840f4e1",
"assets/assets/images/makeup/sparkle.png": "7f3261714489008106a4e339305f81f2",
"assets/assets/images/makeup/heart_broken.png": "52d6d0ab07d8179ceceb8d777ed86bbd",
"assets/assets/images/makeup/pump_bottle.png": "52d6d0ab07d8179ceceb8d777ed86bbd",
"assets/assets/dad_child_wave_2.png~": "8fdc0acab879e2d617ae7e5613c8f676",
"assets/assets/dad_child_wave_2.png": "25dd0c766c5667d8f937d5380afd75ab",
"assets/assets/kindle.png~": "e14ad9c51865ee7d67ff3f1a749040ca",
"assets/assets/dad_child_wave_3.png~": "3fbc0e4c5a1f3157f39fd256f7777f3c",
"assets/assets/popcorn_2.png": "9ad40c28a23800827f77af608000d4cb",
"assets/assets/empty_couch.png~": "2b0a34235899643208ea6a57a2f922ec",
"assets/assets/popcorn_bowl.png": "6067f0a9e845e550bcb4627e251cc41e",
"assets/assets/dad_child_wave_1.png": "1f0fdcbaeb13d6fdf21776da9e9f675c",
"assets/assets/sister_sitting_couch_pressing.png": "a7312d23376b34ecdc6510a41a5a0450",
"assets/assets/popcorn_1.png": "1ed9ad0826b2182d94c64f33c51d2df8",
"assets/assets/kindle.png": "19a6939fd96914f4b66b20a25126cb60",
"assets/assets/empty_couch.png": "3149a563302e871a96cac6b036569d3c",
"assets/assets/dad_child_wave_3.png": "3fbc0e4c5a1f3157f39fd256f7777f3c",
"assets/fonts/MaterialIcons-Regular.otf": "b0e12aab242f197e2e48e6daa7de65d5",
"assets/NOTICES": "6bfd14c0110f89f35df407ff909db43b",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.bin": "3e77c8d946a9bae9ef6e153c0d232de1",
"canvaskit/chromium/canvaskit.wasm": "a726e3f75a84fcdf495a15817c63a35d",
"canvaskit/chromium/canvaskit.js": "a80c765aaa8af8645c9fb1aae53f9abf",
"canvaskit/chromium/canvaskit.js.symbols": "e2d09f0e434bc118bf67dae526737d07",
"canvaskit/skwasm_heavy.wasm": "b0be7910760d205ea4e011458df6ee01",
"canvaskit/skwasm_heavy.js.symbols": "0755b4fb399918388d71b59ad390b055",
"canvaskit/skwasm.js": "8060d46e9a4901ca9991edd3a26be4f0",
"canvaskit/canvaskit.wasm": "9b6a7830bf26959b200594729d73538e",
"canvaskit/skwasm_heavy.js": "740d43a6b8240ef9e23eed8c48840da4",
"canvaskit/canvaskit.js": "8331fe38e66b3a898c4f37648aaf7ee2",
"canvaskit/skwasm.wasm": "7e5f3afdd3b0747a1fd4517cea239898",
"canvaskit/canvaskit.js.symbols": "a3c9f77715b642d0437d9c275caba91e",
"canvaskit/skwasm.js.symbols": "3a4aadf4e8141f284bd524976b1d6bdc",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter_bootstrap.js": "e11b868fd27ea9d951c11e8694c431a0",
"version.json": "d17db98767da9153931e2b4bc6c33dc2",
"main.dart.js": "2c30ab55f8b3a2cc904ed377eb14c97c"};
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
