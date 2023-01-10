class BiomeAttributes {
  String name;
  num offset;
  num scale;
  num terrainHeight;
  num terrainScale;
  num surfaceBlock;
  num subSurfaceBlock;
  int majorFloraIndex;
  num majorFloraZoneScale;
  num majorFloraPlacementScale;
  num majorFloraPlacementThreshold;
  bool placeMajorFlora;
  num maxHeight;
  num minHeight;
  List<Lode> lodes;

  BiomeAttributes({this.name = '', this.offset = 0, this.scale = 1, this.terrainHeight = 0,
    this.terrainScale = 1, this.subSurfaceBlock = 0, this.surfaceBlock = 0,
    this.majorFloraIndex = 0, this.majorFloraZoneScale = 1.3, this.majorFloraPlacementScale = 15,
    this.majorFloraPlacementThreshold = 0.8, this.placeMajorFlora = true,
    this.maxHeight = 12, this.minHeight = 5, this.lodes = const []});
}

class Lode {
  String name;
  int blockId;
  num minHeight;
  num maxHeight;
  num scale;
  num threshold;
  num noiseOffset;
  Lode({ this.name = '', this.blockId = 0, this.minHeight = 0, this.maxHeight = 0,
    this.scale = 1, this.threshold = 0, this.noiseOffset = 0 });
}
