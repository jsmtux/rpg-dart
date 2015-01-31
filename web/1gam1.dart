import 'dart:html';

import 'package:game_loop/game_loop_html.dart';
import 'package:vector_math/vector_math.dart';

import 'behaviour.dart';
import 'renderer.dart';
import 'element.dart';
import 'game_state.dart';
import 'base_geometry.dart';
import 'terrain_importer.dart';
import 'square_terrain.dart';
import 'model_importer.dart';

void AddTerrainList(List<SquareTerrain> list, GameState state)
{
  for (SquareTerrain sq in list)
  {
    BaseGeometry terrain_geom = sq.calculateBaseGeometry(state.elements_.length * 0.001);

    EngineElement e1 = state.addElement(terrain_geom, null);
    Quaternion rot = new Quaternion.identity();
    //rot.setAxisAngle(new Vector3(1.0, 0.0, 0.0 ), -60 * (math.PI / 180));
    e1.drawable_.rotation_ *= rot;
  }
}

void AddElement(List<BaseGeometry> list, GameState state)
{
  for (BaseGeometry geom in list)
  {
    EngineElement el = state.addElement(geom, new Tile3dBehaviour(4,1));
    el.drawable_.size = 1/3;
  }
}

main() {
  CanvasElement canvas = querySelector(".game-element");
  GameLoopHtml gameLoop = new GameLoopHtml(canvas);

  Renderer renderer = new Renderer(canvas);
  GameState draw_state = new GameState(renderer);

  renderer.m_worldview_.translate(-5.0, -2.0, -15.0);
  renderer.m_worldview_.rotate(new Vector3(-1.0,0.0,0.0), radians(45.0));
  Function cb = (list) => AddTerrainList(list, draw_state);

  TerrainImporter importer = new TerrainImporter.Async(cb);
  importer.RequestFile("images/test.json");

  Function cb2 = (list) => AddElement(list, draw_state);
  ModelImporter importer2 = new ModelImporter.Async(cb2);
  importer2.RequestFile('images/tree.model');

  gameLoop.state = draw_state;

  gameLoop.start();
}
