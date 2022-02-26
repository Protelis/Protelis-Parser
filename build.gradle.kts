import org.w3c.dom.Document
import org.w3c.dom.Node
import org.w3c.dom.NodeList
import javax.xml.parsers.DocumentBuilderFactory
import javax.xml.transform.TransformerFactory
import javax.xml.transform.dom.DOMSource
import javax.xml.transform.stream.StreamResult

tasks.register("injectVersion") {
    doLast {
        val transformer = TransformerFactory.newInstance().newTransformer()
        val newVersion = requireNotNull(project.property("newVersion")) { "run with -PnewVersion=..." }.toString()
        val files = file(".").walkTopDown()
        files.filter { it.name == "pom.xml" }.forEach { xmlFile ->
            val document = DocumentBuilderFactory.newInstance().newDocumentBuilder().parse(xmlFile)
            val project = document["project"]
            project?.get("version")?.textContent = newVersion
            project?.get("parent")?.get("version")?.textContent = newVersion
            transformer.transform(DOMSource(document), StreamResult(xmlFile))
        }
        files.filter { it.name == "MANIFEST.MF" }.forEach {
            it.replace(Regex("""Bundle-Version:\s*\d+\.\d+\.\d+"""), "Bundle-Version: $newVersion")
        }
        files.filter { it.name == "feature.xml" }.forEach {
            it.replace(Regex("version=\"\\d+\\.\\d+\\.\\d+\""), "version=\"$newVersion\"")
        }
    }
}

fun NodeList.toSequence(): Sequence<Node> = object : Sequence<Node> {
    override fun iterator(): Iterator<Node> = object : Iterator<Node> {
        var index = 0
        override fun hasNext() = length > index
        override fun next() = if (hasNext()) item(index++) else throw NoSuchElementException()
    }
}

operator fun Document.get(name: String) = childNodes[name]
operator fun Node.get(name: String) = childNodes[name]
operator fun NodeList.get(name: String) = toSequence().find { it.nodeName == name }
fun File.replace(regex: Regex, replacement: String) = writeText(readText().replace(regex, replacement))
