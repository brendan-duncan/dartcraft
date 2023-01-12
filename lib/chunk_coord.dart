class ChunkCoord {
  int x;
  int z;

  ChunkCoord(this.x, this.z);

  void setFrom(ChunkCoord other) {
    x = other.x;
    z = other.z;
  }

  @override
  bool operator==(Object other) =>
    other is ChunkCoord && other.x == x && other.z == z;

  @override
  int get hashCode => '$x,$z'.hashCode;

  String toString() => '$x,$z';
}
