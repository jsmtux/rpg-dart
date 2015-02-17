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
  AnimationData animation_pc = new AnimationData();
  animation_pc.num_images_side_ = 16;
  animation_pc.sequences_ = new Map<String, AnimationSequence>();
  animation_pc.sequences_["walk_t"] = new AnimationSequence([1, 2, 3, 4, 5, 6, 7, 8], 0.1);
  animation_pc.sequences_["walk_l"] = new AnimationSequence([17, 18, 19, 20, 21, 22, 23, 24], 0.1);
  animation_pc.sequences_["walk_b"] = new AnimationSequence([33, 34, 35, 36, 37, 38, 39, 40], 0.1);
  animation_pc.sequences_["walk_r"] = new AnimationSequence([49, 50, 51, 52, 53, 54, 55, 56], 0.1);
  animation_pc.sequences_["stand_t"] = new AnimationSequence([0], 0.1);
  animation_pc.sequences_["stand_l"] = new AnimationSequence([16], 0.1);
  animation_pc.sequences_["stand_b"] = new AnimationSequence([32], 0.1);
  animation_pc.sequences_["stand_r"] = new AnimationSequence([48], 0.1);
  animation_pc.sequences_["stab_t"] = new AnimationSequence([128, 129, 130, 131, 132, 133], 0.05);
  animation_pc.sequences_["stab_l"] = new AnimationSequence([144, 145, 146, 147, 148, 149], 0.05);
  animation_pc.sequences_["stab_b"] = new AnimationSequence([160 ,161, 162, 163, 164, 165], 0.05);
  animation_pc.sequences_["stab_r"] = new AnimationSequence([176, 177, 178, 179, 180, 181], 0.05);
  BaseGeometry quad = new TexturedGeometry(quad_vertices, quad_indices, quad_coords, "images/pc.png");
  EngineElement e2 = state.addElement(drawable_factory.createAnimatedDrawable(quad, animation_pc) ,
      new PCBehaviour(20.0, 15.0, terrain, gameLoop.keyboard, cur_cam));

  AnimationData animation_skeleton = new AnimationData();
  animation_skeleton.num_images_side_ = 8;
  animation_skeleton.sequences_ = new Map<String, AnimationSequence>();
  animation_skeleton.sequences_["stab_t"] = new AnimationSequence([0, 1, 2, 3, 4, 5, 6], 0.1);
  animation_skeleton.sequences_["stab_l"] = new AnimationSequence([8, 9, 10, 11, 12, 13, 14], 0.1);
  animation_skeleton.sequences_["stab_b"] = new AnimationSequence([16, 17, 18, 19, 20, 21, 22], 0.1);
  animation_skeleton.sequences_["stab_r"] = new AnimationSequence([24, 25, 26, 27, 28, 29, 30], 0.1);
  animation_skeleton.sequences_["walk_t"] = new AnimationSequence([32, 33, 34, 35, 36, 37, 38, 39], 0.1);
  animation_skeleton.sequences_["walk_l"] = new AnimationSequence([40, 41, 42, 43, 44, 45, 46, 47], 0.1);
  animation_skeleton.sequences_["walk_b"] = new AnimationSequence([48, 49, 50, 51, 52, 53, 54, 55], 0.1);
  animation_skeleton.sequences_["walk_r"] = new AnimationSequence([56, 57, 58, 59, 60, 61, 62, 63], 0.1);
  animation_skeleton.sequences_["die"] = new AnimationSequence([31, 7, 15, 23, 31], 0.2);
  BaseGeometry quad_skeleton = new TexturedGeometry(quad_vertices, quad_indices, quad_coords, "images/skeletonspear.png");
  EngineElement e3 = state.addElement(drawable_factory.createAnimatedDrawable(quad_skeleton, animation_skeleton) ,
      new EnemyBehaviour(14.0, 14.0, terrain, gameLoop.keyboard));
  EngineElement e4 = state.addElement(drawable_factory.createAnimatedDrawable(quad_skeleton, animation_skeleton) ,
      new EnemyBehaviour(25.0, 14.0, terrain, gameLoop.keyboard));

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
