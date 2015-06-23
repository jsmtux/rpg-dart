library enemy_behaviour;

import 'package:vector_math/vector_math.dart';

import '../game_area.dart';
import '../path.dart';
import 'path_follower.dart';
import 'behaviour.dart';
import 'terrain_element_behaviour.dart';
import 'sheep_behaviour.dart';

class EnemyNormalState extends WalkingBehaviourState
{
  PathFollower path_follower_;

  EnemyNormalState(SpriteBehaviour element, Path path) : super(element, 0.03)
  {
    path_follower_ = new MapPathFollower(path);
  }

  void hit(SpriteBehaviour sprite)
  {
    EnemyBehaviour element = element_;
    element_.setState(element.dead_state_);
  }

  void update()
  {
    bool walking = true;
    for (Behaviour behaviour in element_.area_.behaviours_)
    {
      double min_distance;
      SheepBehaviour closest_sheep;
      if (behaviour is SheepBehaviour && ! behaviour.isDead())
      {
        double dist = element_.squareDistance(behaviour);
        if (min_distance == null || dist < min_distance)
        {
          min_distance = dist;
          closest_sheep = behaviour;
        }
      }
      if (closest_sheep != null && min_distance < 12)
      {
        element_.setState(new EnemyFollowState(element_, closest_sheep));
      }
    }
    if (walking)
    {
      path_follower_.updateWalk(this);
    }
  }
}

class EnemyFollowState extends WalkingBehaviourState
{
  SheepBehaviour follow_;

  EnemyFollowState(SpriteBehaviour element, this.follow_) : super(element, 0.05);
  void hit(SpriteBehaviour sprite){}

  void update()
  {
    Vector2 diff = (follow_.position_ - element_.position_);
    walkDir(diff);
    EnemyBehaviour this_element = element_;
    if (diff.length2 < 0.1)
    {
      follow_.hit(element_);
      element_.setState(this_element.normal_state_);
    }
    if (diff.length2 > 20)
    {
      element_.setState(this_element.normal_state_);
    }
  }
}

class EnemyDeadState extends BehaviourState
{
  EnemyDeadState(SpriteBehaviour element) : super(element);

  void begin()
  {
    element_.anim_drawable_.SetSequence("die", 1);
  }

  void hit(SpriteBehaviour sprite)
  {
  }

  void update()
  {
  }
}

class EnemyBehaviour extends SpriteBehaviour
{
  bool dead_ = false;
  EnemyDeadState dead_state_;
  EnemyNormalState normal_state_;

  EnemyBehaviour(GameArea area, Path path)
    : super(new Vector2(path.points[0].x.floorToDouble(), path.points[0].y.floorToDouble()), area)
  {
    dead_state_ = new EnemyDeadState(this);
    normal_state_ = new EnemyNormalState(this, path);
    cur_state_ = normal_state_;
  }
}