{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    # Java Development Kit
    jdk17
    
    # Build tools
    maven
    gradle
    
    # Language servers
    jdt-language-server
    
    # Spring Boot CLI
    spring-boot-cli
    
    # Additional Java tools
    lombok
    
    # Development tools
    git
    curl
    wget
    
    # Database tools (useful for Spring Boot)
    postgresql
    redis
    
    # Container tools
    docker
    docker-compose
  ];

  shellHook = ''
    export JAVA_HOME=${pkgs.jdk17.home}
    export PATH=$JAVA_HOME/bin:$PATH
    
    # Spring Boot specific environment
    export SPRING_PROFILES_ACTIVE=dev
    
    echo "Java Spring Boot development environment ready!"
    echo "Java version: $(java -version 2>&1 | head -n 1)"
    echo "Maven version: $(mvn -version | head -n 1)"
    echo "Gradle version: $(gradle --version | grep "Gradle" | head -n 1)"
  '';
}
