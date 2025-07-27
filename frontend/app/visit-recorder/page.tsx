'use client'

import React, { useState } from 'react'
import MainLayout from '../../components/MainLayout'
import VideoPreview from '../../components/visit-recorder/VideoPreview'
import MicButton from '../../components/visit-recorder/MicButton'
import NotesPanel from '../../components/visit-recorder/NotesPanel'

export default function VisitRecorder() {
  const [isRecording, setIsRecording] = useState(false)
  const [visitId, setVisitId] = useState<string | null>(null)
  const [recordingTime, setRecordingTime] = useState(0)
  const [gpsAccuracy, setGpsAccuracy] = useState(3.2)

  const handleStartRecording = () => {
    const newVisitId = `visit_${Date.now()}`
    setVisitId(newVisitId)
    setIsRecording(true)
    console.log('Recording started:', newVisitId)
  }

  const handleStopRecording = () => {
    setIsRecording(false)
    console.log('Recording stopped, uploading data...')
  }

  if (!visitId) {
    return (
      <MainLayout>
        <div className="flex items-center justify-center min-h-[60vh]">
          <div className="text-center space-y-6">
            <div className="text-6xl mb-4">📹</div>
            <h1 className="text-3xl font-bold text-gray-800">Visit Recorder</h1>
            <p className="text-gray-600 max-w-md">
              現地調査を開始してください。カメラ、音声、メモが自動的に記録されます。
            </p>
            <button
              onClick={handleStartRecording}
              className="bg-risk-alert text-white px-8 py-4 rounded-xl text-xl font-semibold hover:bg-red-600 transition-all transform hover:scale-105"
            >
              🎬 調査開始
            </button>
          </div>
        </div>
      </MainLayout>
    )
  }

  return (
    <MainLayout>
      <div className="space-y-4">
        {/* ステータスバー */}
        <div className="bg-white rounded-lg shadow-md p-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-4">
              <div className="flex items-center gap-2">
                <div className={`w-3 h-3 rounded-full ${isRecording ? 'bg-risk-alert animate-pulse' : 'bg-gray-400'}`}></div>
                <span className="font-semibold">Visit ID: {visitId}</span>
              </div>
              
              {isRecording && (
                <div className="flex items-center gap-2 text-risk-alert">
                  <span>🎙️</span>
                  <span className="font-mono">
                    {Math.floor(recordingTime / 60)}:{(recordingTime % 60).toString().padStart(2, '0')}
                  </span>
                </div>
              )}
            </div>
            
            <div className="flex items-center gap-4 text-sm text-gray-600">
              <div className="flex items-center gap-1">
                <span>📍</span>
                <span>GPS精度: {gpsAccuracy}m</span>
              </div>
              
              <button
                onClick={handleStopRecording}
                className="bg-gray-800 text-white px-4 py-2 rounded-lg hover:bg-gray-900 transition-colors"
              >
                📤 終了 & Upload
              </button>
            </div>
          </div>
        </div>

        {/* 3ペインレイアウト */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-4 h-[calc(100vh-200px)]">
          {/* カメラパネル */}
          <div className="bg-white rounded-lg shadow-md p-4">
            <div className="flex items-center gap-2 mb-4">
              <span className="text-xl">📷</span>
              <h2 className="font-semibold">Camera</h2>
            </div>
            <VideoPreview isRecording={isRecording} />
          </div>

          {/* オーディオパネル */}
          <div className="bg-white rounded-lg shadow-md p-4">
            <div className="flex items-center gap-2 mb-4">
              <span className="text-xl">🎙️</span>
              <h2 className="font-semibold">Audio</h2>
            </div>
            <MicButton 
              isRecording={isRecording}
              onToggle={() => setIsRecording(!isRecording)}
            />
          </div>

          {/* ノートパネル */}
          <div className="bg-white rounded-lg shadow-md p-4">
            <div className="flex items-center gap-2 mb-4">
              <span className="text-xl">✏️</span>
              <h2 className="font-semibold">Notes</h2>
            </div>
            <NotesPanel visitId={visitId} />
          </div>
        </div>
      </div>
    </MainLayout>
  )
}