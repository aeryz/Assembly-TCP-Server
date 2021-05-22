// Client side C/C++ program to demonstrate Socket programming
#include <arpa/inet.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <time.h>
#include <unistd.h>
#define PORT 4444

int main(int argc, char const *argv[]) {
  srand(time(NULL));
  int sock = 0, valread;
  struct sockaddr_in serv_addr;
  char *hello = "Hello World!";
  char *hello2 = "Hello World 2!";
  char *hello3 = "Hello World 3!";
  char *arr[3] = {hello, hello2, hello3};
  char buffer[1024] = {0};
  if ((sock = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
    printf("\n Socket creation error \n");
    return -1;
  }

  serv_addr.sin_family = AF_INET;
  serv_addr.sin_port = htons(PORT);

  // Convert IPv4 and IPv6 addresses from text to binary form
  if (inet_pton(AF_INET, "127.0.0.1", &serv_addr.sin_addr) <= 0) {
    printf("\nInvalid address/ Address not supported \n");
    return -1;
  }

  if (connect(sock, (struct sockaddr *)&serv_addr, sizeof(serv_addr)) < 0) {
    printf("\nConnection Failed \n");
    return -1;
  }
  char *msg = arr[rand() % 3];
  printf("%ld\n", send(sock, msg, strlen(msg), 0));
  printf("Hello message sent\n");
  valread = read(sock, buffer, 1024);
  printf("%s\n", buffer);
  close(sock);
  return 0;
}
