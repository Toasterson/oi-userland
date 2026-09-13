// SPDX-License-Identifier: CDDL-1.0
#include <QFile>
#include <QGuiApplication>
#include <QJSEngine>
#include <QQmlComponent>
#include <QQmlContext>
#include <QQmlEngine>
#include <QQmlPropertyMap>
#include <QTemporaryDir>
#include <Qt3DQuickRender/private/quick3dshaderdata_p.h>
#include <Qt3DRender/private/qshaderdata_p.h>
#include <iostream>
#include <memory>
#include <stdexcept>

static void check(bool ok, const char *message) {
    if (!ok)
        throw std::runtime_error(message);
}

int main(int argc, char **argv) {
    // Keep every trash operation inside this test's scratch directory.
    QTemporaryDir scratch;
    check(scratch.isValid(), "scratch directory failed");
    qputenv("XDG_DATA_HOME", scratch.path().toUtf8());
    QGuiApplication app(argc, argv);
    try {
        const QString input = scratch.filePath("discard.txt");
        QFile file(input);
        check(file.open(QIODevice::WriteOnly), "create trash fixture failed");
        file.write("qt6-trash-fixture");
        file.close();
        QString trashed;
        check(QFile::moveToTrash(input, &trashed), "moveToTrash failed");
        check(!QFile::exists(input) && QFile::exists(trashed), "trash destination missing");
        check(trashed.startsWith(scratch.path() + '/'), "trash escaped scratch directory");
        QFile result(trashed);
        check(result.open(QIODevice::ReadOnly) && result.readAll() == "qt6-trash-fixture", "trash content changed");

        QQmlEngine engine;
        std::unique_ptr<QQmlPropertyMap> map(QQmlPropertyMap::create());
        map->insert("amount", 3);
        engine.rootContext()->setContextProperty("values", map.get());
        QQmlComponent component(&engine);
        component.setData("import QtQml\nQtObject { property int result: values.amount * 2 }", QUrl());
        std::unique_ptr<QObject> object(component.create());
        check(object != nullptr, qPrintable(component.errorString()));
        check(object->property("result").toInt() == 6, "initial map binding failed");
        map->insert("amount", 4);
        check(object->property("result").toInt() == 8, "map binding did not update");

        Qt3DRender::Render::Quick::Quick3DShaderData data;
        auto priv = static_cast<Qt3DRender::QShaderDataPrivate *>(Qt3DCore::QNodePrivate::get(&data));
        auto read = [&](QJSValue value) { return priv->m_propertyReader->readProperty(QVariant::fromValue(value)); };
        check(read(engine.evaluate("[1, 2, 3]")).toList().size() == 3, "shader array conversion failed");
        check(read(engine.evaluate("42")).toInt() == 42, "shader number conversion failed");
        check(read(engine.evaluate("true")).toBool(), "shader bool conversion failed");
        auto jsObject = engine.evaluate("({ answer: 42 })");
        check(read(jsObject).value<QJSValue>().strictlyEquals(jsObject), "shader JS object identity lost");

        QQmlComponent datavis(&engine);
        datavis.setData("import QtQuick\nimport QtDataVisualization\nItem { property Theme3D theme: Theme3D {} }", QUrl());
        std::unique_ptr<QObject> view(datavis.create());
        check(view != nullptr, qPrintable(datavis.errorString()));
        for (const char *name : {"Bars3D.qml", "Scatter3D.qml", "Surface3D.qml"}) {
            const QUrl url(QStringLiteral("qrc:/qt-project.org/imports/QtDataVisualization/designer/default/")
                           + QString::fromLatin1(name));
            QQmlComponent designer(&engine, url);
            check(designer.isReady(), qPrintable(designer.errorString()));
        }
        std::cout << "Trash, property-map bindings, shader conversions, DataVisualization import and designer compilation passed\n";
        return 0;
    } catch (const std::exception &error) {
        std::cerr << error.what() << '\n';
        return 1;
    }
}
