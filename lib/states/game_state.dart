import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../services/sound_manager.dart';
import '../widgets/ammo.dart';
import '../widgets/bombs.dart';
import '../widgets/explosion.dart';
import '../widgets/item.dart';

class GameState extends ChangeNotifier {
  // app bar global key
  GlobalKey appBarKey = GlobalKey();

  // airplane position and size
  double airplaneX = 0.0;
  double airplaneY = 10.0;
  double airplaneSize = 70.0;

  // app bar panel data
  int score = 0;
  int healthPoints = 5;

  // ammo width and height
  double ammoWidth = 5.0;
  double ammoHeight = 15.0;

  // ammo list
  List<AmmoData> ammos = [];

  // ammo timer
  Timer? ammoMoveTimer;
  Timer? ammoFireTimer;

  // item and bomb timers
  Timer? itemGenerateTimer;
  Timer? bombGenerateTimer;

  // ammo move speed
  double ammoMoveSpeed = 8;

  // ammo fire speed - adjusted to better match sound effects
  int ammoFireSpeed = 300;

  // move speed
  double moveSpeed = 2;

  // items
  List<Item> items = [];

  // explosions
  List<Explosion> explosions = [];

  // bombs
  List<Bombs> bombs = [];

  // bomb size
  double bombSize = 50.0;

  // is show full screen explosion
  bool isShowFullScreenExplosion = false;

  // Flag to track if game over dialog is already shown
  bool isGameOverDialogShown = false;

  // Screen dimensions
  double screenWidth = 0.0;
  double screenHeight = 0.0;
  double appBarHeight = 0.0;

  // Min item size
  double minItemSize = 10.0;
  // Max item size
  double maxItemSize = 50.0;

  // Sound manager instance
  final SoundManager _soundManager = SoundManager();

  // Initialize game state
  void initGame(BuildContext context) {
    // Reset game over dialog flag
    isGameOverDialogShown = false;

    // Reset health points
    healthPoints = 5;

    // Reset score
    score = 0;

    // Clear existing game elements
    ammos.clear();
    items.clear();
    explosions.clear();
    bombs.clear();

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    appBarHeight =
        appBarKey.currentContext?.findRenderObject()?.paintBounds.bottom ?? 0;

    // init airplane x value
    airplaneX = screenWidth / 2 - airplaneSize / 2;

    // Initialize sound manager
    _soundManager.initialize();

    // Play background music
    _soundManager.playBackgroundMusic();

    // start move ammo
    startAmmoMovement();

    // start generate items
    startGenerateItems();

    // start generate bombs
    startGenerateBombs();

    notifyListeners();
  }

  @override
  void dispose() {
    ammoMoveTimer?.cancel();
    ammoFireTimer?.cancel();
    itemGenerateTimer?.cancel();
    bombGenerateTimer?.cancel();
    super.dispose();
  }

  // stop game
  void stopGame(BuildContext context) {
    ammoMoveTimer?.cancel();
    ammoFireTimer?.cancel();
    itemGenerateTimer?.cancel();
    bombGenerateTimer?.cancel();
    for (Item item in List.from(items)) {
      item.stop();
    }
    for (Bombs bomb in List.from(bombs)) {
      bomb.stop();
    }

    // Play game over sound
    _soundManager.playGameOverSound();

    // Pause background music
    _soundManager.pauseBackgroundMusic();

    // Game over dialog will be handled in the UI
  }

  // check bomb colliding
  bool isBombColliding(AmmoData ammo, Bombs bomb) {
    // ammo boundary
    double ammoLeft = ammo.x;
    double ammoTop = ammo.y;
    double ammoRight = ammo.x + ammoWidth;
    double ammoBottom = ammo.y + ammoHeight;

    // bomb boundary
    double bombLeft = bomb.x;
    double bombTop = bomb.y;
    double bombRight = bomb.x + bombSize;
    double bombBottom = bomb.y + bombSize;

    return ammoLeft < bombRight &&
        ammoRight > bombLeft &&
        ammoBottom > bombTop &&
        ammoTop < bombBottom;
  }

  // check bomb collisions
  void checkBombCollisions() {
    for (AmmoData ammo in List.from(ammos)) {
      for (Bombs bomb in List.from(bombs)) {
        if (isBombColliding(ammo, bomb)) {
          ammos.remove(ammo);
          bombs.remove(bomb);
          triggerFullScreenExplosion();
          break;
        }
      }
    }
    notifyListeners();
  }

  // trigger full screen explosion
  void triggerFullScreenExplosion() {
    healthPoints--;
    isShowFullScreenExplosion = true;

    // Play explosion sound
    _soundManager.playExplosionSound();

    notifyListeners();

    Future.delayed(
      Duration(seconds: 1),
      () {
        isShowFullScreenExplosion = false;
        notifyListeners();
      },
    );
  }

  // start generate bombs
  void startGenerateBombs() {
    // Cancel existing timer if it exists
    bombGenerateTimer?.cancel();

    bombGenerateTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      bombs.add(Bombs(
        key: GlobalKey<BombsState>(),
        speed: moveSpeed,
        onRemove: (bomb) {
          bombs.remove(bomb);
          notifyListeners();
        },
        initX: Random().nextDouble() * (screenWidth - bombSize),
        initSize: bombSize,
      ));
      notifyListeners();
    });
  }

  // check item colliding
  bool isItemColliding(AmmoData ammo, Item item) {
    // ammo boundary
    double ammoLeft = ammo.x;
    double ammoRight = ammo.x + ammoWidth;
    double ammoTop = ammo.y;
    double ammoBottom = ammo.y + ammoHeight;

    // item boundary
    double itemLeft = item.x;
    double itemRight = item.x + item.size;
    double itemTop = item.y;
    double itemBottom = item.y + item.size;

    // check
    return ammoRight > itemLeft &&
        ammoLeft < itemRight &&
        ammoBottom > itemTop &&
        ammoTop < itemBottom;
  }

  // check item collisions
  void checkItemCollisions() {
    for (AmmoData ammo in List.from(ammos)) {
      for (Item item in List.from(items)) {
        if (isItemColliding(ammo, item)) {
          ammos.remove(ammo);
          items.remove(item);
          explosions.add(Explosion(
            key: UniqueKey(),
            x: item.x,
            y: item.y,
            color: item.color,
            onComplete: (explosion) {
              explosions.remove(explosion);
              notifyListeners();
            },
          ));
          score++;

          // Play item collect and explosion sounds
          _soundManager.playItemCollectSound();

          notifyListeners();
        }
      }
    }
  }

  // start generate items
  void startGenerateItems() {
    // Cancel existing timer if it exists
    itemGenerateTimer?.cancel();

    itemGenerateTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      // init size
      final initSize =
          Random().nextDouble() * (maxItemSize - minItemSize) + minItemSize;

      // init x
      final initX = Random().nextDouble() * (screenWidth - initSize);

      items.add(Item(
        key: GlobalKey<ItemState>(),
        speed: moveSpeed,
        onRemove: (item) {
          items.remove(item);
          notifyListeners();
        },
        initX: initX,
        initSize: initSize,
      ));
      notifyListeners();
    });
  }

  // start ammo move
  void startAmmoMovement() {
    ammoMoveTimer = Timer.periodic(Duration(milliseconds: 16), (timer) {
      for (var bullet in ammos) {
        // ammo y + 10
        bullet.y += ammoMoveSpeed;
      }

      // remove the overflow screen ammo
      ammos.removeWhere((bullet) => bullet.y > screenHeight);

      // check item collisions
      checkItemCollisions();

      // check bomb collisions
      checkBombCollisions();

      notifyListeners();
    });

    ammoFireTimer =
        Timer.periodic(Duration(milliseconds: ammoFireSpeed), (timer) {
      fireAmmo();
    });
  }

  // fire ammo
  void fireAmmo() {
    ammos.add(
      AmmoData(
        x: airplaneX + airplaneSize / 2 - ammoWidth / 2,
        y: airplaneY + airplaneSize,
      ),
    );

    // Play fire sound
    _soundManager.playFireSound();

    notifyListeners();
  }

  // update position
  void updateAirplanePosition(DragUpdateDetails details) {
    final position = details.globalPosition;

    // update airplane position
    airplaneX =
        (position.dx - airplaneSize / 2).clamp(0.0, screenWidth - airplaneSize);
    airplaneY = (screenHeight - position.dy - airplaneSize / 2)
        .clamp(0.0, screenHeight - airplaneSize - appBarHeight);

    // Play airplane move sound (uncomment if you want continuous sound on movement)
    _soundManager.playAirplaneMoveSound();

    notifyListeners();
  }
}
