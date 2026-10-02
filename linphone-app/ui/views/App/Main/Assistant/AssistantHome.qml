import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import ConstantsCpp 1.0

import App.Styles 1.0

// =============================================================================

ColumnLayout {
	id: nuvvOnboarding
	spacing: 20
	anchors.centerIn: parent
	Layout.alignment: Qt.AlignCenter
	width: Math.min(parent.width * 0.85, 480)

	AssistantModel {
		id: assistantModel
		property string qrcode
	}

	Connections {
		target: SettingsModel
		onRemoteProvisioningChanged: {
			activationStatus.text = qsTr('Configuração recebida com sucesso! Reiniciando...')
			App.restart()
		}
		onRemoteProvisioningNotChanged: {
			activationStatus.text = qsTr('Falha ao obter provisionamento. Verifique o endereço ou token informado.')
			activateButton.enabled = true
		}
	}

	Connections {
		target: assistantModel
		onQRCodeFound: {
			provisionUrlInput.text = token
			SettingsModel.remoteProvisioning = token
		}
		onProvisioningTokenReceived: {
			provisionUrlInput.text = token
			SettingsModel.remoteProvisioning = token
		}
	}

	// ---------------------------------------------------------------------------
	// Cabeçalho e Identidade Visual Nuvv
	// ---------------------------------------------------------------------------
	ColumnLayout {
		Layout.alignment: Qt.AlignHCenter
		Layout.fillWidth: true
		spacing: 8

		Icon {
			Layout.alignment: Qt.AlignHCenter
			icon: 'linphone_logo'
			iconSize: 72
		}

		Text {
			Layout.alignment: Qt.AlignHCenter
			font {
				bold: true
				pixelSize: 22
			}
			color: '#0A3B74' // Deep Blue Nuvv
			text: 'Nuvv Connect'
		}

		Text {
			Layout.alignment: Qt.AlignHCenter
			font.pixelSize: 13
			color: '#718096'
			text: qsTr('Comunicação corporativa segura e integrada')
		}
	}

	// ---------------------------------------------------------------------------
	// Card de Ativação
	// ---------------------------------------------------------------------------
	Rectangle {
		Layout.fillWidth: true
		Layout.preferredHeight: cardLayout.implicitHeight + 36
		color: '#FFFFFF'
		radius: 12
		border.color: '#E2E8F0'
		border.width: 1

		ColumnLayout {
			id: cardLayout
			anchors {
				top: parent.top
				left: parent.left
				right: parent.right
				margins: 18
			}
			spacing: 14

			Text {
				text: qsTr('Ativação do Dispositivo')
				font {
					bold: true
					pixelSize: 15
				}
				color: '#051D3B'
			}

			Text {
				text: qsTr('Informe o endereço do servidor ou token fornecido pela sua equipe de TI:')
				font.pixelSize: 12
				color: '#718096'
				wrapMode: Text.WordWrap
				Layout.fillWidth: true
			}

			TextField {
				id: provisionUrlInput
				Layout.fillWidth: true
				placeholderText: 'https://provision.nuvv.com.br ou Token'
				selectByMouse: true
			}

			TextButtonA {
				id: activateButton
				Layout.fillWidth: true
				Layout.preferredHeight: 44
				enabled: provisionUrlInput.text.trim().length > 0 && cguCheckBox.checked
				text: qsTr('Ativar Dispositivo')

				onClicked: {
					enabled = false
					activationStatus.text = qsTr('Conectando ao provisionamento Nuvv...')
					SettingsModel.remoteProvisioning = provisionUrlInput.text.trim()
				}
			}

			TextButtonB {
				id: qrCodeButton
				Layout.fillWidth: true
				Layout.preferredHeight: 38
				visible: SettingsModel.isQRCodeAvailable()
				text: qsTr('Escanear QR Code de Ativação')
				onClicked: {
					assistant.pushView('FetchRemoteConfiguration', {})
				}
			}

			Text {
				id: activationStatus
				Layout.fillWidth: true
				horizontalAlignment: Text.AlignHCenter
				font.pixelSize: 12
				color: '#00A896'
				wrapMode: Text.WordWrap
				text: ''
			}
		}
	}

	// ---------------------------------------------------------------------------
	// Termos e Políticas
	// ---------------------------------------------------------------------------
	CheckBoxText {
		id: cguCheckBox
		Layout.alignment: Qt.AlignHCenter
		Layout.fillWidth: true
		checked: true
		text: qsTr('Concordo com os <a href="%1">Termos de Uso</a> e a <a href="%2">Política de Privacidade</a> da Nuvv.').arg(ConstantsCpp.CguUrl).arg(ConstantsCpp.PrivatePolicyUrl)
	}
}
