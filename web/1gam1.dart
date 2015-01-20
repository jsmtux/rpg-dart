import 'dart:html';
import 'dart:math' as math;

import 'package:game_loop/game_loop_html.dart';
import 'package:vector_math/vector_math.dart';

import 'renderer.dart';
import 'element.dart';
import 'game_state.dart';
import 'base_geometry.dart';
import 'geometry_data.dart';
import 'square_terrain.dart';

main() {
  CanvasElement canvas = querySelector(".game-element");
  GameLoopHtml gameLoop = new GameLoopHtml(canvas);

  Renderer renderer = new Renderer(canvas);
  GameState draw_state = new GameState(renderer);

  renderer.m_worldview_.translate(0.0, 0.0, -10.0);
  //renderer.m_worldview_.rotate(new Vector3(1.0,0.0,0.0), radians(-45.0));

  //BaseGeometry quad = new TexturedGeometry(quad_vertices, quad_indices, quad_coords, "nehe.gif");

  //EngineElement e1 = draw_state.addElement(quad, null);

  List<List<int>> heights = new List<List<int>>();
  heights.add(new List<int>());
  heights[0].add(0);
  heights[0].add(0);
  heights[0].add(0);
  heights.add(new List<int>());
  heights[1].add(0);
  heights[1].add(-2);
  heights[1].add(1);
  heights.add(new List<int>());
  heights[2].add(0);
  heights[2].add(1);
  heights[2].add(1);

  List<List<int>> textures = new List<List<int>>();
  textures.add(new List<int>());
  textures[0].add(1);
  textures[0].add(1);
  textures[0].add(0);
  textures.add(new List<int>());
  textures[1].add(2);
  textures[1].add(3);
  textures[1].add(3);
  textures.add(new List<int>());
  textures[2].add(2);
  textures[2].add(3);
  textures[2].add(3);

  SquareTerrain terrain = new SquareTerrain(new Vector2(3.0, 3.0), heights, "nehe.gif", textures, 4);

  BaseGeometry terrain_geom = terrain.calculateBaseGeometry();

  EngineElement e1 = draw_state.addElement(terrain_geom, null);
  Quaternion rot = new Quaternion.identity();
  rot.setAxisAngle(new Vector3(1.0, 0.0, 0.0 ), -60 * (math.PI / 180));
  e1.drawable_.rotation_ *= rot;

  gameLoop.state = draw_state;

  gameLoop.start();
}
