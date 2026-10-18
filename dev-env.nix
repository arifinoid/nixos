{
  pkgs ? import <nixpkgs> { },
}:

pkgs.mkShell {
  buildInputs = with pkgs; [
    jdk17

    maven
    gradle
    jdt-language-server
    spring-boot-cli
    lombok

    git
    curl
    wget

    # Database tools (useful for Spring Boot)
    postgresql
    redis

    docker
    docker-compose
  ];

  shellHook = ''
    
    
        export JAVA_HOME=${pkgs.jdk17.home}
        export PATH=$JAVA_HOME/bin:$PATH
    
        export SPRING_PROFILES_ACTIVE=dev
    
        echo "Java Spring Boot development environment ready!"
        echo "Java version: $(java -version 2>&1 | head -n 1)"
        echo "Maven version: $(mvn -version | head -n 1)"
        echo "Gradle version: $(gradle --version | grep "Gradle" | head -n 1)"
  '';
}
