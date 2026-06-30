import 'dart:convert';

/// Parses the backend response that boots a new assistant session.
AssistantStartResponse assistantStartResponseFromJson(String str) =>
    AssistantStartResponse.fromJson(json.decode(str));

String assistantStartResponseToJson(AssistantStartResponse data) =>
    json.encode(data.toJson());

/// Top-level session payload returned by `/customer/assistant/start` and refresh endpoints.
class AssistantStartResponse {
  bool? status;
  Data? data;

  AssistantStartResponse({this.status, this.data});

  factory AssistantStartResponse.fromJson(Map<String, dynamic> json) =>
      AssistantStartResponse(
        status: json["status"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"status": status, "data": data?.toJson()};
}

/// Nested assistant session metadata used by the realtime controller to connect OpenAI and Anam.
class Data {
  String? sessionId;
  String? ephemeralToken;
  int? expiresAt;
  String? model;
  String? voice;
  String? avatarId;
  String? anamSessionToken;
  String? systemPrompt;
  List<Tool>? tools;
  List<ContextMessage>? contextMessages;

  Data({
    this.sessionId,
    this.ephemeralToken,
    this.expiresAt,
    this.model,
    this.voice,
    this.avatarId,
    this.anamSessionToken,
    this.systemPrompt,
    this.tools,
    this.contextMessages,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    sessionId: json["session_id"],
    ephemeralToken: json["ephemeral_token"],
    expiresAt: json["expires_at"],
    model: json["model"],
    voice: json["voice"],
    avatarId: json["avatar_id"],
    anamSessionToken: json["anam_session_token"],
    systemPrompt: json["system_prompt"],
    tools: json["tools"] == null
        ? []
        : List<Tool>.from(json["tools"]!.map((x) => Tool.fromJson(x))),
    contextMessages: json["context_messages"] == null
        ? []
        : List<ContextMessage>.from(
            json["context_messages"]!.map((x) => ContextMessage.fromJson(x)),
          ),
  );

  Map<String, dynamic> toJson() => {
    "session_id": sessionId,
    "ephemeral_token": ephemeralToken,
    "expires_at": expiresAt,
    "model": model,
    "voice": voice,
    "avatar_id": avatarId,
    "anam_session_token": anamSessionToken,
    "system_prompt": systemPrompt,
    "tools": tools == null
        ? []
        : List<dynamic>.from(tools!.map((x) => x.toJson())),
    "context_messages": contextMessages == null
        ? []
        : List<dynamic>.from(contextMessages!.map((x) => x.toJson())),
  };
}

/// Backend-supplied context message that can be replayed into the realtime conversation.
class ContextMessage {
  String? role;
  String? content;

  ContextMessage({this.role, this.content});

  factory ContextMessage.fromJson(Map<String, dynamic> json) =>
      ContextMessage(role: json["role"], content: json["content"]);

  Map<String, dynamic> toJson() => {"role": role, "content": content};
}

/// Tool definition exposed by the backend and registered with the realtime websocket client.
class Tool {
  String? type;
  String? name;
  String? description;
  Parameters? parameters;

  Tool({this.type, this.name, this.description, this.parameters});

  factory Tool.fromJson(Map<String, dynamic> json) => Tool(
    type: json["type"],
    name: json["name"],
    description: json["description"],
    parameters: json["parameters"] == null
        ? null
        : Parameters.fromJson(json["parameters"]),
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "name": name,
    "description": description,
    "parameters": parameters?.toJson(),
  };
}

/// JSON-schema-like parameter bag for each backend tool.
class Parameters {
  String? type;
  Map<String, dynamic>? properties;
  List<String>? required;

  Parameters({this.type, this.properties, this.required});

  factory Parameters.fromJson(Map<String, dynamic> json) => Parameters(
    type: json["type"],
    properties: json["properties"],
    required: json["required"] == null
        ? []
        : List<String>.from(json["required"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "properties": properties,
    "required": required == null
        ? []
        : List<dynamic>.from(required!.map((x) => x)),
  };
}
