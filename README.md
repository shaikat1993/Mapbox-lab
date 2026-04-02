# Mapbox-lab

✓ Why this structure?
Features are self-contained vertical slices. Each feature owns its
 View + ViewModel + Model. 
 
 The Core/ layer has zero knowledge of features — it provides shared contracts via protocols. 
 
 Services/ implement those protocols. This enforces the Dependency Inversion Principle before we write a line of Mapbox code.


Why do we use MBXAccessToken instead of MGLMapboxAccessToken in Info.plist?
ANSWER: MBXAccessToken is the v11 key. Using the v6 key (MGLMapboxAccessToken) results in a blank map at runtime with no error message.