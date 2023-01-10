class BlockType {
  String name;
  bool isSolid;
  bool renderNeighborFaces;
  num opacity;
  List<int> textures;

  BlockType({this.name = '', this.isSolid = false, this.renderNeighborFaces = false,
    this.opacity = 0, this.textures = const [0, 0, 0, 0, 0, 0]});
}
