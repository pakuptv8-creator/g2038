Define.DefaultSceneRatio = 1.7777777777777777
Define.ABILITY = {
  MOVE = Bitwise64.Sl(1, 1),
  SCALE = Bitwise64.Sl(1, 2),
  ROTATE = Bitwise64.Sl(1, 3),
  TRANSFORM = Bitwise64.Or(Bitwise64.Sl(1, 1), Bitwise64.Sl(1, 2), Bitwise64.Sl(1, 3)),
  AABB = Bitwise64.Sl(1, 4),
  HAVELENGTH = Bitwise64.Sl(1, 5),
  ANCHORSPACE = Bitwise64.Sl(1, 6),
  FOCUS = Bitwise64.Sl(1, 7),
  FORCE_UPRIGHT = Bitwise64.Sl(1, 8),
  SELECTABLE = Bitwise64.Sl(1, 9)
}
Define.CLASS_ABILITY = {
  Part = Bitwise64.Or(Define.ABILITY.TRANSFORM, Define.ABILITY.AABB, Define.ABILITY.FOCUS, Define.ABILITY.SELECTABLE),
  PartOperation = Bitwise64.Or(Define.ABILITY.TRANSFORM, Define.ABILITY.AABB, Define.ABILITY.FOCUS, Define.ABILITY.SELECTABLE),
  Model = Bitwise64.Or(Define.ABILITY.TRANSFORM, Define.ABILITY.AABB, Define.ABILITY.FOCUS, Define.ABILITY.SELECTABLE),
  MeshPart = Bitwise64.Or(Define.ABILITY.TRANSFORM, Define.ABILITY.AABB, Define.ABILITY.FOCUS, Define.ABILITY.SELECTABLE),
  RodConstraint = Bitwise64.Or(Define.ABILITY.HAVELENGTH, Define.ABILITY.ANCHORSPACE),
  SpringConstraint = Bitwise64.Or(Define.ABILITY.HAVELENGTH, Define.ABILITY.ANCHORSPACE),
  RopeConstraint = Bitwise64.Or(Define.ABILITY.HAVELENGTH, Define.ABILITY.ANCHORSPACE),
  SliderConstraint = Define.ABILITY.ANCHORSPACE,
  Entity = Bitwise64.Or(Define.ABILITY.TRANSFORM, Define.ABILITY.AABB, Define.ABILITY.FOCUS, Define.ABILITY.FORCE_UPRIGHT, Define.ABILITY.SELECTABLE),
  DropItem = Bitwise64.Or(Define.ABILITY.AABB, Define.ABILITY.MOVE, Define.ABILITY.FOCUS, Define.ABILITY.SELECTABLE),
  RegionPart = Bitwise64.Or(Define.ABILITY.MOVE, Define.ABILITY.SCALE, Define.ABILITY.AABB, Define.ABILITY.FOCUS, Define.ABILITY.SELECTABLE),
  VoxelTerrain = Define.ABILITY.FOCUS,
  PartClient = Bitwise64.Or(Define.ABILITY.TRANSFORM, Define.ABILITY.AABB, Define.ABILITY.FOCUS, Define.ABILITY.SELECTABLE),
  PartOperationClient = Bitwise64.Or(Define.ABILITY.TRANSFORM, Define.ABILITY.AABB, Define.ABILITY.FOCUS, Define.ABILITY.SELECTABLE),
  ModelClient = Bitwise64.Or(Define.ABILITY.TRANSFORM, Define.ABILITY.AABB, Define.ABILITY.FOCUS, Define.ABILITY.SELECTABLE),
  MeshPartClient = Bitwise64.Or(Define.ABILITY.TRANSFORM, Define.ABILITY.AABB, Define.ABILITY.FOCUS, Define.ABILITY.SELECTABLE),
  RodConstraintClient = Bitwise64.Or(Define.ABILITY.HAVELENGTH, Define.ABILITY.ANCHORSPACE),
  SpringConstraintClient = Bitwise64.Or(Define.ABILITY.HAVELENGTH, Define.ABILITY.ANCHORSPACE),
  RopeConstraintClient = Bitwise64.Or(Define.ABILITY.HAVELENGTH, Define.ABILITY.ANCHORSPACE),
  SliderConstraintClient = Define.ABILITY.ANCHORSPACE,
  EntityClient = Bitwise64.Or(Define.ABILITY.TRANSFORM, Define.ABILITY.AABB, Define.ABILITY.FOCUS, Define.ABILITY.FORCE_UPRIGHT, Define.ABILITY.SELECTABLE),
  DropItemClient = Bitwise64.Or(Define.ABILITY.AABB, Define.ABILITY.MOVE, Define.ABILITY.FOCUS, Define.ABILITY.SELECTABLE),
  RegionPartClient = Bitwise64.Or(Define.ABILITY.MOVE, Define.ABILITY.SCALE, Define.ABILITY.AABB, Define.ABILITY.FOCUS, Define.ABILITY.SELECTABLE),
  VoxelTerrainClient = Define.ABILITY.FOCUS
}
Define.EntityType = {Player = 1, Palette = 2}
Define.LIMITED_TIME_ACTIVITY_ENTRY = {
  [Define.LIMITED_TIME_ACTIVITY_MENU.LIMITED_TIME_ACTIVITY] = {
    icon = "set:g2052_Activity.json image:icon_0_fisherman02",
    name = "",
    type = Define.LIMITED_TIME_ACTIVITY_MENU.LIMITED_TIME_ACTIVITY,
    effect = ""
  },
  [Define.LIMITED_TIME_ACTIVITY_MENU.COMBINATION_GIFT] = {
    icon = "set:general_limited_time.json image:btn_0_gift_bag2",
    name = "gui.limit.time.combined.title",
    type = Define.LIMITED_TIME_ACTIVITY_MENU.COMBINATION_GIFT,
    effect = "limited_giftpack_entrance_1.effect"
  },
  [Define.LIMITED_TIME_ACTIVITY_MENU.SIGNAL_GIFT] = {
    icon = "set:general_limited_time.json image:btn_0_gift_bag2",
    name = "gui.limit.time.combined.title",
    type = Define.LIMITED_TIME_ACTIVITY_MENU.SIGNAL_GIFT,
    effect = "limited_giftpack_entrance_1.effect"
  }
}
