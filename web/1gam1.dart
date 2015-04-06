import 'dart:html';

import 'package:game_loop/game_loop_html.dart';

import 'renderer.dart';
import 'game_state.dart';
import 'drawable_factory.dart';
import 'camera.dart';
import 'sprite_importer.dart';


main() {
  CanvasElement canvas = querySelector("#game-element");
  DivElement div = querySelector("#game-area");
  GameLoopHtml gameLoop = new GameLoopHtml(canvas);
  gameLoop.pointerLock.lockOnClick = false;

  Renderer renderer = new Renderer(div, canvas);

  DrawableFactory drawable_factory = new DrawableFactory(renderer);
  GameState draw_state = new GameState(renderer);

  Camera cur_cam = new Camera(renderer.m_worldview_);

  SpriteLoader loader = new SpriteLoader(drawable_factory, gameLoop, cur_cam);

  draw_state.loadArea("first", "images/map_test.json", "images/map_units_test.json", loader)
    .then((bool ret)
        {
          loader.gameLoop_.state = draw_state;
          draw_state.setVisible("first", true);
        });
  draw_state.loadArea("second", "images/map_test_2.json", null, loader);

  gameLoop.start();
}
