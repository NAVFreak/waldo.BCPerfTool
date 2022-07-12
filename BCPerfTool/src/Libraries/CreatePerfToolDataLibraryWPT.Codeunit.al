codeunit 62104 "Create PerfToolDataLibrary WPT"
{
    Access = public;

    procedure CreateGroup(GroupCode: Code[20]; Description: Text[100]; var PerfToolGroupWPT: Record "PerfTool Group WPT")
    begin
        PerfToolGroupWPT.Init();

        if PerfToolGroupWPT.Get(GroupCode) then exit;

        PerfToolGroupWPT.Code := GroupCode;
        PerfToolGroupWPT.Description := Description;
        PerfToolGroupWPT.Insert(true);

        Commit();

        OnAfterInsertSuiteGroup(PerfToolGroupWPT);
    end;

    procedure CreateSuite(PerfToolGroupWPT: Record "PerfTool Group WPT"; SuiteCode: Code[20]; Description: Text[50]; var PerfToolSuiteHeader: Record "PerfTool Suite Header WPT")
    begin
        PerfToolSuiteHeader.Init();

        if PerfToolSuiteHeader.Get(SuiteCode) then exit;

        PerfToolSuiteHeader.Code := SuiteCode;
        PerfToolSuiteHeader.Description := Description;
        PerfToolSuiteHeader."Group Code" := PerfToolGroupWPT.Code;
        PerfToolSuiteHeader.Insert(true);

        Commit();

        OnAfterInsertSuiteHeader(PerfToolGroupWPT, PerfToolSuiteHeader);
    end;

    procedure CreateSuiteLine(Header: Record "PerfTool Suite Header WPT"; ObjType: Option; ObjectId: Integer; SelectLatestVersion: Boolean; var Line: Record "PerfTool Suite Line WPT")
    begin
        CreateSuiteLine(Header, ObjType, ObjectId, enum::"PerfToolCodeunit WPT"::Default, '', false, Line);
    end;

    procedure CreateSuiteLine(Header: Record "PerfTool Suite Header WPT"; ObjType: Option; PerfToolCodeunit: enum "PerfToolCodeunit WPT"; ProcedureName: Text[30]; SelectLatestVersion: Boolean; var Line: Record "PerfTool Suite Line WPT")
    begin
        CreateSuiteLine(Header, ObjType, 0, PerfToolCodeunit, ProcedureName, SelectLatestVersion, Line);
    end;

    procedure CreateSuiteLines(Header: Record "PerfTool Suite Header WPT"; ObjType: Option; PerfToolCodeunit: enum "PerfToolCodeunit WPT"; SelectLatestVersion: Boolean; var Line: Record "PerfTool Suite Line WPT")
    var
        PerfToolCodeunitWPT: Interface "PerfToolCodeunit WPT";
        ProcedureName: Text[30];
    begin
        PerfToolCodeunitWPT := PerfToolCodeunit;

        foreach ProcedureName in perftoolcodeunitwpt.GetProcedures() do
            CreateSuiteLine(Header, ObjType, PerfToolCodeunit.AsInteger(), PerfToolCodeunit, ProcedureName, SelectLatestVersion, Line);

    end;

    procedure CreateSuiteLine(Header: Record "PerfTool Suite Header WPT"; ObjType: Option; ObjId: Integer; PerfToolCodeunit: enum "PerfToolCodeunit WPT"; ProcedureName: Text[30]; SelectLatestVersion: Boolean; var Line: Record "PerfTool Suite Line WPT")
    var
        LineNo: Integer;
    begin
        Line.Reset();
        Line.SetRange("PerfTool Code", Header.Code);
        Line.SetRange("Object Type", ObjType);
        Line.SetRange("Object ID", ObjId);
        line.SetRange("Procedure Name", ProcedureName);
        if not line.IsEmpty then exit;

        Line.Reset();
        Line.SetRange("PerfTool Code", Header.Code);
        if Line.FindLast() then
            LineNo := Line."Line No." + 10000
        else
            LineNo := 10000;

        Line.Init();

        Line.validate("PerfTool Code", Header.Code);
        Line.validate("Line No.", LineNo);
        line.validate("Object Type", ObjType);
        Line.validate("Object ID", ObjId);
        line.validate(PerfToolCodeunit, PerfToolCodeunit);
        line.validate("Procedure Name", ProcedureName);
        line.validate(SelectLatestVersion, SelectLatestVersion);

        Line.Insert(true);

        Commit();

        OnAfterInsertSuiteLine(Header, Line);
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterInsertSuiteGroup(var PerfToolGroupWPT: Record "PerfTool Group WPT")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterInsertSuiteHeader(PerfToolGroupWPT: Record "PerfTool Group WPT"; var PerfToolSuiteHeaderWPT: Record "PerfTool Suite Header WPT")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterInsertSuiteLine(PerfToolSuiteHeaderWPT: Record "PerfTool Suite Header WPT"; var PerfToolSuiteLineWPT: Record "PerfTool Suite Line WPT")
    begin
    end;
}