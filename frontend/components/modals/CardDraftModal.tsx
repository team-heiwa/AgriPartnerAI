'use client'

import React, { useState } from 'react'

interface CardDraft {
  id: string
  images: string[]
  summary: string
  tags: string[]
  riskType: 'pest' | 'disease' | 'environment'
  confidenceScore: number
}

interface CardDraftModalProps {
  isOpen: boolean
  onClose: () => void
  drafts: CardDraft[]
  onSaveDraft: (draft: CardDraft, destination: 'active' | 'archive') => void
  onSkipAll: () => void
}

export default function CardDraftModal({ 
  isOpen, 
  onClose, 
  drafts, 
  onSaveDraft, 
  onSkipAll 
}: CardDraftModalProps) {
  const [currentIndex, setCurrentIndex] = useState(0)
  const [editedSummary, setEditedSummary] = useState('')
  const [selectedRiskType, setSelectedRiskType] = useState<'pest' | 'disease' | 'environment'>('pest')
  const [selectedTags, setSelectedTags] = useState<string[]>([])

  if (!isOpen || drafts.length === 0) return null

  const currentDraft = drafts[currentIndex]

  const handleNext = (destination: 'active' | 'archive') => {
    const updatedDraft = {
      ...currentDraft,
      summary: editedSummary || currentDraft.summary,
      riskType: selectedRiskType,
      tags: selectedTags
    }

    onSaveDraft(updatedDraft, destination)

    if (currentIndex < drafts.length - 1) {
      setCurrentIndex(currentIndex + 1)
      const nextDraft = drafts[currentIndex + 1]
      setEditedSummary(nextDraft.summary)
      setSelectedRiskType(nextDraft.riskType)
      setSelectedTags(nextDraft.tags)
    } else {
      onClose()
    }
  }

  const getRiskTypeLabel = (type: string) => {
    switch (type) {
      case 'pest': return '🐛 害虫'
      case 'disease': return '🍂 病気'
      case 'environment': return '🌦️ 環境'
      default: return type
    }
  }

  const availableTags = [
    '#カメムシ候補', '#アブラムシ', '#ハダニ', '#アザミウマ',
    '#灰色かび病', '#うどんこ病', '#べと病', '#黒斑病',
    '#高湿度', '#低温', '#乾燥', '#強風',
    '#要監視', '#緊急対応', '#予防処置'
  ]

  const toggleTag = (tag: string) => {
    setSelectedTags(prev => 
      prev.includes(tag) 
        ? prev.filter(t => t !== tag)
        : [...prev, tag]
    )
  }

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 z-50 flex items-center justify-center p-4">
      <div className="bg-white rounded-xl shadow-2xl max-w-4xl w-full max-h-[90vh] overflow-y-auto">
        {/* ヘッダー */}
        <div className="flex items-center justify-between p-6 border-b">
          <h2 className="text-xl font-bold text-gray-800">
            Card Draft Review #{currentDraft.id}
          </h2>
          <div className="flex items-center gap-4">
            <span className="text-sm text-gray-500">
              {currentIndex + 1} / {drafts.length}
            </span>
            <button
              onClick={onClose}
              className="text-gray-400 hover:text-gray-600 text-xl"
            >
              ×
            </button>
          </div>
        </div>

        <div className="p-6 space-y-6">
          {/* 画像プレビュー */}
          <div className="space-y-3">
            <h3 className="text-sm font-semibold text-gray-700">📸 撮影画像</h3>
            <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
              {currentDraft.images.slice(0, 4).map((image, index) => (
                <img
                  key={index}
                  src={image}
                  alt={`Image ${index + 1}`}
                  className="w-full aspect-video object-cover rounded-lg border border-gray-200"
                />
              ))}
            </div>
          </div>

          {/* 要約編集 */}
          <div className="space-y-3">
            <h3 className="text-sm font-semibold text-gray-700">📝 要約</h3>
            <textarea
              value={editedSummary || currentDraft.summary}
              onChange={(e) => setEditedSummary(e.target.value)}
              className="w-full h-24 p-3 border border-gray-300 rounded-lg resize-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              placeholder="AI生成の要約を編集できます..."
            />
            <div className="flex items-center gap-2 text-xs text-gray-500">
              <span>🤖</span>
              <span>信頼度: {(currentDraft.confidenceScore * 100).toFixed(1)}%</span>
            </div>
          </div>

          {/* リスクタイプ選択 */}
          <div className="space-y-3">
            <h3 className="text-sm font-semibold text-gray-700">🏷️ リスクタイプ</h3>
            <div className="flex gap-3">
              {(['pest', 'disease', 'environment'] as const).map((type) => (
                <button
                  key={type}
                  onClick={() => setSelectedRiskType(type)}
                  className={`
                    px-4 py-2 rounded-lg border transition-all
                    ${selectedRiskType === type
                      ? 'bg-blue-50 border-blue-500 text-blue-700'
                      : 'bg-gray-50 border-gray-300 text-gray-600 hover:bg-gray-100'
                    }
                  `}
                >
                  {getRiskTypeLabel(type)}
                </button>
              ))}
            </div>
          </div>

          {/* タグ選択 */}
          <div className="space-y-3">
            <h3 className="text-sm font-semibold text-gray-700">🏷️ タグ</h3>
            <div className="flex flex-wrap gap-2">
              {availableTags.map((tag) => (
                <button
                  key={tag}
                  onClick={() => toggleTag(tag)}
                  className={`
                    px-3 py-1 rounded-full text-sm transition-all
                    ${selectedTags.includes(tag)
                      ? 'bg-blue-100 text-blue-800 border border-blue-300'
                      : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                    }
                  `}
                >
                  {tag}
                </button>
              ))}
            </div>
          </div>

          {/* 保存先選択 */}
          <div className="space-y-3">
            <h3 className="text-sm font-semibold text-gray-700">💾 保存先</h3>
            <div className="flex gap-4">
              <button
                onClick={() => handleNext('active')}
                className="flex-1 bg-blue-600 text-white px-6 py-3 rounded-lg hover:bg-blue-700 transition-colors flex items-center justify-center gap-2"
              >
                <span>📌</span>
                <span>アクティブに保存</span>
              </button>
              
              <button
                onClick={() => handleNext('archive')}
                className="flex-1 bg-gray-600 text-white px-6 py-3 rounded-lg hover:bg-gray-700 transition-colors flex items-center justify-center gap-2"
              >
                <span>📂</span>
                <span>アーカイブに保存</span>
              </button>
            </div>
          </div>
        </div>

        {/* フッター */}
        <div className="flex items-center justify-between p-6 border-t bg-gray-50">
          <button
            onClick={onSkipAll}
            className="text-gray-600 hover:text-gray-800 px-4 py-2 rounded-lg hover:bg-gray-200 transition-colors"
          >
            全てスキップ
          </button>
          
          <div className="flex gap-2">
            <button
              onClick={() => {
                if (currentIndex > 0) {
                  setCurrentIndex(currentIndex - 1)
                }
              }}
              disabled={currentIndex === 0}
              className="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              ← 前へ
            </button>
            
            <span className="px-4 py-2 text-sm text-gray-500">
              {currentIndex < drafts.length - 1 ? '次へ →' : '完了'}
            </span>
          </div>
        </div>
      </div>
    </div>
  )
}