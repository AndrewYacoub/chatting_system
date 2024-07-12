# Chatting System

## Overview

The Chatting System is a Ruby on Rails application designed for managing applications, chats, and messages with caching implemented using Redis and searching using Elasticsearch. This project also includes a Docker setup for running the necessary services.

## Prerequisites

- Docker
- Docker Compose
- MySQL
- Redis
- Elasticsearch

## How to Run the Project

### 1. Clone the Repository

```bash
git clone https://github.com/AndrewYacoub/chatting_system.git
cd chatting_system
```
### 2. Starting Services
```bash
sudo docker-compose down && sudo docker-compose build && sudo docker-compose up
```
### 4. URLs and APIs
#### Applications
List all applications
```bash
URL: GET /applications
```
```bash
response: 
[
  {
    "id": 1,
    "name": "First Application",
    "token": "d9ec39ec2bd83cabd6b5",
    "chats_count": 1,
    "created_at": "2024-07-09T13:06:16.664Z",
    "updated_at": "2024-07-09T13:06:16.664Z"
  },
  {
    "id": 2,
    "name": "Second Application",
    "token": "f2d4340d6110e9517037",
    "chats_count": 0,
    "created_at": "2024-07-09T14:29:28.532Z",
    "updated_at": "2024-07-09T14:29:28.532Z"
  }
]
```
Create a new application
```bash
URL: POST /applications
```
```bash
Request Body:
{
  "name": "New Application"
}
response: 
{
  "token": "newly_generated_token"
}
```
Get a specific application
```bash
URL: GET /applications/:token
```
```bash
Response:
{
  "id": 1,
  "name": "First Application",
  "token": "d9ec39ec2bd83cabd6b5",
  "chats_count": 1,
  "created_at": "2024-07-09T13:06:16.664Z",
  "updated_at": "2024-07-09T13:06:16.664Z"
}
```
Update a specific application
```bash
URL: PUT /applications/:token
```
```bash
Request Body:
{
  "name": "Updated Application"
}
```
```bash
Response:
{
  "id": 1,
  "name": "Updated Application",
  "token": "d9ec39ec2bd83cabd6b5",
  "chats_count": 1,
  "created_at": "2024-07-09T13:06:16.664Z",
  "updated_at": "2024-07-09T13:06:16.664Z"
}
```
Delete a specific application

```bash
URL: DELETE /applications/:token
```
```bash
Response:
{
  "message": "Application deleted successfully"
}
```
#### Chats
List all chats for an application
```bash
URL: GET /applications/:application_token/chats
```
```bash
Response:
[
  {
    "id": 1,
    "number": 1,
    "application_id": 1,
    "created_at": "2024-07-09T13:06:16.664Z",
    "updated_at": "2024-07-09T13:06:16.664Z"
  }
]
```
Create a new chat for an application
```bash
URL: POST /applications/:application_token/chats
```
```bash
Response:
{
  "number": 1
}
```
Get a specific chat
```bash
URL: GET /applications/:application_token/chats/:number
```

```bash
Response:
{
  "id": 1,
  "number": 1,
  "application_id": 1,
  "created_at": "2024-07-09T13:06:16.664Z",
  "updated_at": "2024-07-09T13:06:16.664Z"
}
```
Delete a specific chat
```bash
URL: DELETE /applications/:application_token/chats/:number
```
```bash
Response:
{
  "message": "Chat deleted successfully"
}
```
#### Messages
List all messages for a chat
```bash
URL: GET /applications/:application_token/chats/:chat_number/messages
```

```bash
Response:

[
  {
    "id": 1,
    "body": "First message",
    "chat_id": 1,
    "created_at": "2024-07-09T13:06:16.664Z",
    "updated_at": "2024-07-09T13:06:16.664Z"
  }
]
```
Create a new message for a chat
```bash
URL: POST /applications/:application_token/chats/:chat_number/messages
```
```bash
Request Body:
{
  "body": "New message"
}
```
```bash
Response:
{
  "id": 1,
  "body": "New message",
  "chat_id": 1,
  "created_at": "2024-07-09T13:06:16.664Z",
  "updated_at": "2024-07-09T13:06:16.664Z"
}
```
Get a specific message
```bash
URL: GET /applications/:application_token/chats/:chat_number/messages/:id
```
```bash
Response:
{
  "id": 1,
  "body": "First message",
  "chat_id": 1,
  "created_at": "2024-07-09T13:06:16.664Z",
  "updated_at": "2024-07-09T13:06:16 &#8203;:citation[oaicite:0]{index=0}&#8203;
}
```
Search in messages
```bash
URL: GET /applications/:application_token/chats/:chat_number/messages/search?query=First
```
```bash
Response:
{
  "id": 1,
  "body": "First message",
  "chat_id": 1,
  "created_at": "2024-07-09T13:06:16.664Z",
  "updated_at": "2024-07-09T13:06:16 &#8203;:citation[oaicite:0]{index=0}&#8203;
}
```