'use client'

import React, { useState } from 'react'

interface NotesPanelProps {
  visitId: string
}

export default function NotesPanel({ visitId }: NotesPanelProps) {
  const [notes, setNotes] = useState('')
  const [savedNotes, setSavedNotes] = useState<Array<{
    id: string
    timestamp: Date
    content: string
    source: 'manual' | 'voice'
  }>>([])

  const handleSaveNote = () => {
    if (!notes.trim()) return

    const newNote = {
      id: `note_${Date.now()}`,
      timestamp: new Date(),
      content: notes.trim(),
      source: 'manual' as const
    }

    setSavedNotes(prev => [newNote, ...prev])
    setNotes('')
    console.log('ノート保存:', newNote)
  }

  const handleVoiceTranscription = () => {
    // 実際には音声認識APIを使用
    const transcribedText = "音声から変換されたテキストの例です。葉っぱに虫の痕跡が見られます。"
    
    const newNote = {
      id: `note_${Date.now()}`,
      timestamp: new Date(),
      content: transcribedText,
      source: 'voice' as const
    }

    setSavedNotes(prev => [newNote, ...prev])
    console.log('音声テキスト貼り付け:', newNote)
  }

  const formatTime = (date: Date) => {
    return date.toLocaleTimeString('ja-JP', { 
      hour: '2-digit', 
      minute: '2-digit' 
    })
  }

  return (
    <div className="h-full flex flex-col space-y-4">
      {/* メモ入力エリア */}
      <div className="space-y-3">
        <textarea
          value={notes}
          onChange={(e) => setNotes(e.target.value)}
          placeholder="仮説、観察メモ、気づいたことなどを記録..."
          className="w-full h-32 p-3 border border-gray-300 rounded-lg resize-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
        />
        
        <div className="flex gap-2">
          <button
            onClick={handleSaveNote}
            disabled={!notes.trim()}
            className="flex-1 bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 disabled:bg-gray-300 disabled:cursor-not-allowed transition-colors"
          >
            💾 保存
          </button>
          
          <button
            onClick={handleVoiceTranscription}
            className="bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700 transition-colors"
            title="音声認識で文字起こし"
          >
            🎤→📝
          </button>
        </div>
      </div>

      {/* 保存済みノート一覧 */}
      <div className="flex-1 space-y-2">
        <h3 className="text-sm font-semibold text-gray-700 flex items-center gap-2">
          <span>📋</span>
          保存済みメモ ({savedNotes.length})
        </h3>
        
        <div className="space-y-2 max-h-64 overflow-y-auto">
          {savedNotes.map((note) => (
            <div
              key={note.id}
              className={`
                p-3 rounded-lg border text-sm
                ${note.source === 'voice' 
                  ? 'bg-green-50 border-green-200' 
                  : 'bg-gray-50 border-gray-200'
                }
              `}
            >
              <div className="flex items-center justify-between mb-1">
                <span className="text-xs text-gray-500">
                  {formatTime(note.timestamp)}
                </span>
                <span className="text-xs">
                  {note.source === 'voice' ? '🎤' : '✏️'}
                </span>
              </div>
              <p className="text-gray-800 leading-relaxed">
                {note.content}
              </p>
            </div>
          ))}
        </div>

        {savedNotes.length === 0 && (
          <div className="text-center py-8 text-gray-500">
            <span className="text-2xl block mb-2">📝</span>
            <p className="text-sm">まだメモがありません</p>
          </div>
        )}
      </div>

      {/* クイックアクション */}
      <div className="border-t pt-3">
        <div className="text-xs text-gray-500 mb-2">クイック入力</div>
        <div className="flex flex-wrap gap-2">
          {['健康状態良好', '害虫発見', '病気の疑い', '要追加調査'].map((template) => (
            <button
              key={template}
              onClick={() => setNotes(prev => prev + (prev ? '\n' : '') + template)}
              className="text-xs bg-gray-100 hover:bg-gray-200 px-2 py-1 rounded transition-colors"
            >
              {template}
            </button>
          ))}
        </div>
      </div>
    </div>
  )
}