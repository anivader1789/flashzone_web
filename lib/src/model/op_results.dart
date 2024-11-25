abstract class FZError {
  String message;
  FZError({required this.message});

  String errorMessage();
}

class FirebaseError extends FZError {
  FirebaseError({required super.message});
  
  @override
  String errorMessage() {
    return "FirebaseError: $message";
  }

  @override
  String toString() => errorMessage();
}

class LocalError extends FZError {
  LocalError({required super.message});
  
  @override
  String errorMessage() {
    return "LocalError: $message";
  }

  @override
  String toString() => errorMessage();
}

class RemoteOpError extends FZError {
  RemoteOpError({required super.message});
  
  @override
  String errorMessage() {
    return "RemoteOpError: $message";
  }

  @override
  String toString() => errorMessage();
}

class UnknownError extends FZError {
  UnknownError({required super.message});
  
  @override
  String errorMessage() {
    return "UnknownError: $message";
  }

  @override
  String toString() => errorMessage();
}

class FZResult {
  SuccessCode code;
  String? message;
  dynamic returnedObject;
  FZResult({required this.code, this.message, this.returnedObject});
}

enum SuccessCode {
    successful,
    unknown,
    failed,
    withdrawn
  }
  