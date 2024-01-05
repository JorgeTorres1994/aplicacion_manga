class DetallePuntuacion {
  final String idUsuario;
  final String idManga;
  final double numeroRating;
  final double rating;

  DetallePuntuacion({
    required this.idUsuario,
    required this.idManga,
    required this.numeroRating,
    required this.rating,
  });

  Map<String, dynamic> toMap() {
    return {
      'idUsuario': idUsuario,
      'idManga': idManga,
      'numeroRating': numeroRating,
      'rating': rating,
    };
  }
}
