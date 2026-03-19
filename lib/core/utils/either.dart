sealed class Either<L, R> {
  const Either();

  bool get isLeft => this is Left<L, R>;
  bool get isRight => this is Right<L, R>;

  L get left {
    if (this is Left<L, R>) {
      return (this as Left<L, R>).value;
    }
    throw StateError('Either is not Left');
  }

  R get right {
    if (this is Right<L, R>) {
      return (this as Right<L, R>).value;
    }
    throw StateError('Either is not Right');
  }

  T fold<T>(T Function(L) onLeft, T Function(R) onRight) {
    return switch (this) {
      Left(value: final l) => onLeft(l),
      Right(value: final r) => onRight(r),
    };
  }
}

class Left<L, R> extends Either<L, R> {
  final L value;
  const Left(this.value);

  @override
  String toString() => 'Left($value)';

  @override
  bool operator ==(Object other) {
    return other is Left<L, R> && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}

class Right<L, R> extends Either<L, R> {
  final R value;
  const Right(this.value);

  @override
  String toString() => 'Right($value)';

  @override
  bool operator ==(Object other) {
    return other is Right<L, R> && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}