local ipairs = ipairs

local filenames = {
	"topics.txt",
	"Morrowind.cel",
	"tes3cn_Morrowind.ext.txt",
	"tes3cn_Tribunal.ext.txt",
	"tes3cn_Bloodmoon.ext.txt",
}

local forbids = arg[1] and arg or {
	"������", -- ������
	"������", -- ������
	"������", -- �ϵ���
	"������", -- �ϵ���
	"�ն���", -- ���Ȼ
	"ϣ����", -- ������
	"�ҽ���", -- �ҽ��ɺ�
	"�ҽ���", -- �ҽ��ɺ�
	"������", -- �����ɺ�
	"������", -- �����ɺ�
	"������˹", -- ������˹
	"��٤����", -- �ܸ�����
	"л������˹", -- л������
	"�յ���", -- ������� Redaynia
	"��˹��", -- ��˹������ Resdaynia
}

for _, filename in ipairs(filenames) do
	local i = 0
	for line in io.lines(filename) do
		i = i + 1
		for _, forbid in ipairs(forbids) do
			if line:find(forbid, 1, true) then
				print(filename .. "(" .. i .. "): " .. forbid)
			end
		end
	end
end

print "done!"
