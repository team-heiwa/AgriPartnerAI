'use client'

import React, { useState } from 'react'
import MainLayout from '../../components/MainLayout'
import KanbanBoard from '../../components/actions/KanbanBoard'
import ActionDetail from '../../components/actions/ActionDetail'
import VoiceMemoModal from '../../components/actions/VoiceMemoModal'

export default function ActionsBoard() {
  const [selectedAction, setSelectedAction] = useState<string | null>(null)
  const [isVoiceMemoOpen, setIsVoiceMemoOpen] = useState(false)
  const [activeActionForMemo, setActiveActionForMemo] = useState<string | null>(null)

  const handleVoiceMemo = (actionId: string) => {
    setActiveActionForMemo(actionId)
    setIsVoiceMemoOpen(true)
  }

  return (
    <MainLayout>
      <div className="space-y-6">
        <div className="flex items-center justify-between">
          <h1 className="text-2xl font-bold text-gray-800">Actions Board</h1>
          <div className="flex items-center gap-4">
            <button className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors">
              ➕ 新規アクション
            </button>
            <button className="bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700 transition-colors">
              📊 レポート生成
            </button>
          </div>
        </div>

        <div className="grid grid-cols-1 xl:grid-cols-4 gap-6">
          {/* Kanbanボード */}
          <div className="xl:col-span-3">
            <KanbanBoard
              onActionSelect={setSelectedAction}
              onVoiceMemo={handleVoiceMemo}
              selectedAction={selectedAction}
            />
          </div>

          {/* アクション詳細 */}
          <div className="xl:col-span-1">
            <ActionDetail
              actionId={selectedAction}
              onClose={() => setSelectedAction(null)}
              onVoiceMemo={() => selectedAction && handleVoiceMemo(selectedAction)}
            />
          </div>
        </div>
      </div>

      {/* ボイスメモモーダル */}
      <VoiceMemoModal
        isOpen={isVoiceMemoOpen}
        onClose={() => {
          setIsVoiceMemoOpen(false)
          setActiveActionForMemo(null)
        }}
        actionId={activeActionForMemo}
      />
    </MainLayout>
  )
}