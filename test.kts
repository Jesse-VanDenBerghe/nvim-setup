class TestClass {
    fun test() {
        println("test")
    }

    fun test2() {
        println("test2")
        this.test()
    }
}

fun main() {
    val testClass = TestClass()
    testClass.test()
}
