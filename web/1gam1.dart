import 'dart:html';

import 'package:game_loop/game_loop_html.dart';

import 'renderer.dart';
import 'game_state.dart';
import 'drawable_factory.dart';
import 'camera.dart';


main() {
  CanvasElement canvas = querySelector(".game-element");
  GameLoopHtml gameLoop = new GameLoopHtml(canvas);

  Renderer renderer = new Renderer(canvas);
  DrawableFactory drawable_factory = new DrawableFactory(renderer);
  GameState draw_state = new GameState(renderer);

  Camera cur_cam = new Camera(renderer.m_worldview_);

  draw_state.loadTerrain("images/map_test.json", drawable_factory)
    .then((res) => draw_state.initBehaviour("images/map_units_test.json",res, draw_state, drawable_factory, gameLoop, cur_cam));

  gameLoop.start();
}
