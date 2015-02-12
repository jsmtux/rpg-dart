import 'dart:html';
import 'dart:async';

import 'package:game_loop/game_loop_html.dart';

import 'animation.dart';
import 'renderer.dart';
import 'game_state.dart';
import 'drawable_factory.dart';
import 'level_importer.dart';
import 'level_data.dart';
import 'behaviour.dart';
import 'geometry_data.dart';
import 'base_geometry.dart';
import 'element.dart';
import 'camera.dart';

void initGame (TerrainBehaviour terrain, GameState state, DrawableFactory drawable_factory, GameLoopHtml gameLoop, Camera cur_cam)
{
  AnimationData animation = new AnimationData();
  animation.num_images_side_ = 8;
  animation.sequences_ = new Map<String, AnimationSequence>();
  animation.sequences_["walk_t"] = new AnimationSequence([0, 1, 2, 3, 4, 5, 6, 7], 0.1);
  animation.sequences_["walk_l"] = new AnimationSequence([8, 9,10,11,12,13,14,15], 0.1);
  animation.sequences_["walk_b"] = new AnimationSequence([16,16,18,19,20,21,22,23], 0.1);
  animation.sequences_["walk_r"] = new AnimationSequence([24,25,26,27,28,29,30,31], 0.1);
  BaseGeometry quad = new TexturedGeometry(quad_vertices, quad_indices, quad_coords, "images/pc.png");
  EngineElement e2 = state.addElement(drawable_factory.createAnimatedDrawable(quad, animation) ,
      new PCBehaviour(5.0, 5.0, terrain, gameLoop.keyboard, cur_cam));
  gameLoop.start();
}

main() {
  CanvasElement canvas = querySelector(".game-element");
  GameLoopHtml gameLoop = new GameLoopHtml(canvas);

  Renderer renderer = new Renderer(canvas);
  DrawableFactory drawable_factory = new DrawableFactory(renderer);
  GameState draw_state = new GameState(renderer);

  LevelImporter level_importer = new LevelImporter();
  Future<TerrainBehaviour> import_res =
      level_importer.RequestFile("images/map_test.json").then((LevelData data) => (data.AddToGameState(draw_state, drawable_factory)));

  Camera cur_cam = new Camera(renderer.m_worldview_);

  gameLoop.state = draw_state;

  import_res.then((res) => initGame(res, draw_state, drawable_factory, gameLoop, cur_cam));
}
