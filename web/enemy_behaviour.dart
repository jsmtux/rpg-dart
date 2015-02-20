library enemy_behaviour;

import 'behaviour.dart';
import 'game_state.dart';
import 'path_follower.dart';
import 'path.dart';

class EnemyBehaviour extends WalkingBehaviour
{
  bool dead_ = false;
  PathFollower path_follower_;

  EnemyBehaviour(TerrainBehaviour terrain, Path path) : super(path.position.x.floorToDouble(), path.position.y.floorToDouble(), terrain)
  {
    vel_ = 0.03;
    path_follower_ = new MapPathFollower(path);
  }

  void hit(SpriteBehaviour behaviour)
  {
    if(!dead_)
    {
     dead_ = true;
     anim_drawable_.SetSequence("die", 1);
    }
  }

  void update(GameState state)
  {
    if (!dead_)
    {
      path_follower_.updateWalk(this);
    }
  }
}