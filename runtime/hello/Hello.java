public class Hello {
  public static void main(String[] args) {
    // Heap-allocated message must survive a full GC (card table fix check).
    String msg = new StringBuilder("Hello from ART 6 on QNX!").append(" gc ok").toString();
    System.gc();
    System.out.println(msg);
  }
}
