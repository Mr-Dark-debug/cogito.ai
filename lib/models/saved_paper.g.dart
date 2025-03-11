// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_paper.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavedPaperAdapter extends TypeAdapter<SavedPaper> {
  @override
  final int typeId = 2;

  @override
  SavedPaper read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavedPaper(
      id: fields[0] as String,
      title: fields[1] as String,
      authors: fields[2] as String,
      summary: fields[3] as String,
      pdfUrl: fields[4] as String,
      webUrl: fields[5] as String,
      categories: (fields[6] as List).cast<String>(),
      publishedDate: fields[7] as DateTime,
      savedDate: fields[8] as DateTime,
      localPdfPath: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SavedPaper obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.authors)
      ..writeByte(3)
      ..write(obj.summary)
      ..writeByte(4)
      ..write(obj.pdfUrl)
      ..writeByte(5)
      ..write(obj.webUrl)
      ..writeByte(6)
      ..write(obj.categories)
      ..writeByte(7)
      ..write(obj.publishedDate)
      ..writeByte(8)
      ..write(obj.savedDate)
      ..writeByte(9)
      ..write(obj.localPdfPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedPaperAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
